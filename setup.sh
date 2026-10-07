#!/bin/bash
set -e

CONFIG=$HOME/Develop/config
XDG_CONFIG=$HOME/.config
APP_SUPPORT="$HOME/Library/Application Support"

# brew
command -v brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export HOMEBREW_NO_AUTO_UPDATE=1

brew_install() {
  local flag=$1; shift
  brew install $flag "$@" 2>&1 | grep -Ev "(already installed|To reinstall)" || true
}

brew_install "" \
  nvim tree-sitter-cli `# editor (tree-sitter-cli: compiles nvim-treesitter parsers)` \
  fzf rg fd `# search & find` \
  bat jq yq sd `# file viewing & data processing` \
  zoxide yazi `# file navigation` \
  mediainfo `# yazi previews` \
  clipboard wget vjeantet/tap/alerter `# system utilities (alerter: clickable notifications)` \
  ouch `# compression & archives` \
  imagemagick ffmpeg `# media processing` \
  lazygit delta git-lfs gh lefthook `# git tools` \
  lld@20 `# the linker .cargo/config.toml names` \
  lua go node dotnet `# languages & runtimes` \
  awscli `# cloud & cli tools` \
  just starship shellcheck zsh-autosuggestions `# shell tools`

brew_install --cask \
  kitty `# terminal emulator` \
  hammerspoon `# macOS automation` \
  libreoffice font-hack-nerd-font \
  tailscale `# mesh VPN for stable Mac Mini access` \
  gureumkim `# Korean input method` \
  syntax-highlight `# Finder Quick Look for source files; also declares .jsonc, which macOS leaves untyped`

# bun — its own installer, not brew: $BUN_INSTALL is what PATH and remote PM2 interpreters point at
if [ -x "$HOME/.bun/bin/bun" ]; then
  "$HOME/.bun/bin/bun" upgrade
else
  curl -fsSL https://bun.sh/install | bash
fi

# rustup — its own installer, not brew: each Rust repo pins its toolchain in rust-toolchain.toml, which
# only rustup's cargo honors
[ -x "$HOME/.cargo/bin/rustup" ] || curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
export PATH="$HOME/.cargo/bin:$PATH"

# shell
touch ~/.hushlogin
ln -sf "$CONFIG/.zshenv" ~/.zshenv
ln -sf "$CONFIG/.zshenv.local" ~/.zshenv.local
ln -sf "$CONFIG/.zshrc" ~/.zshrc
ln -sf "$CONFIG/starship.toml" "$XDG_CONFIG/starship.toml"

# git
ln -sf "$CONFIG/git/.gitconfig" ~/.gitconfig
ln -sf "$CONFIG/git/.gitignore_global" ~/.gitignore_global
git config --file ~/.gitconfig.local delta.syntax-theme kanagawa

# ssh
ln -sf "$CONFIG/.ssh/config" ~/.ssh/config

# nvim
rm -rf "$XDG_CONFIG/nvim"
ln -s "$CONFIG/nvim" "$XDG_CONFIG/nvim"

# kitty
rm -rf "$XDG_CONFIG/kitty"
ln -s "$CONFIG/kitty" "$XDG_CONFIG/kitty"

# yazi
rm -rf "$XDG_CONFIG/yazi"
ln -s "$CONFIG/yazi" "$XDG_CONFIG/yazi"
ln -sf theme-kanagawa.toml "$CONFIG/yazi/theme.toml"

# bat
rm -rf "$XDG_CONFIG/bat"
ln -s "$CONFIG/bat" "$XDG_CONFIG/bat"
bat cache --build

# lazygit
rm -rf "$APP_SUPPORT/lazygit"
ln -s "$CONFIG/lazygit" "$APP_SUPPORT/lazygit"

# karabiner - manual sync required
# Karabiner-Elements replaces symlinks with regular files when saving.
# Use: cd karabiner && just export (or just import)
# mkdir -p "$XDG_CONFIG/karabiner"
# ln -sf "$CONFIG/karabiner/karabiner.json" "$XDG_CONFIG/karabiner/karabiner.json"

# hammerspoon
rm -rf ~/.hammerspoon
ln -s "$CONFIG/.hammerspoon" ~/.hammerspoon

# vscode — source lives in vscode/, not .vscode/, so .vscode/ can hold this repo's own workspace settings
mkdir -p "$APP_SUPPORT/Code/User"
ln -sf "$CONFIG/vscode/settings.json" "$APP_SUPPORT/Code/User/settings.json"
ln -sf "$CONFIG/vscode/keybindings.json" "$APP_SUPPORT/Code/User/keybindings.json"

# jetbrains ideavim
ln -sf "$CONFIG/intellij/.ideavimrc" ~/.ideavimrc

# cargo
mkdir -p ~/.cargo
ln -sf "$CONFIG/.cargo/config.toml" ~/.cargo/config.toml

# cargo tools (stylua: lua formatter, upextract: .unitypackage extractor)
cargo install stylua upextract

# agents (claude, codex)
LLM_GLOBAL="$CONFIG/.claude/CLAUDE.global.md"
mkdir -p ~/.claude
ln -sf "$LLM_GLOBAL" ~/.claude/CLAUDE.md
ln -sf "$CONFIG/.claude/settings.json" ~/.claude/settings.json
ln -sf "$CONFIG/.claude/statusline.sh" ~/.claude/statusline.sh
ln -sf "$CONFIG/.claude/notify-done.sh" ~/.claude/notify-done.sh
ln -sf "$CONFIG/.claude/skills-global" ~/.claude/skills
# Register the icon-only helper so alerter --sender can resolve it (see .claude/notify-done.sh).
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$CONFIG/.claude/app/ClaudeSender.app" || true
mkdir -p ~/.codex
ln -sf "$LLM_GLOBAL" ~/.codex/AGENTS.md

# quicklook — Syntax Highlight skips dynamic UTIs, so FileTypes.app declares the Unity extensions macOS leaves
# untyped. Syntax Highlight's settings live in the unsandboxed ~/Library/Preferences plist its renderer reads; a bare
# `defaults write <domain>` lands in the app's sandbox container instead.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$CONFIG/quicklook/FileTypes.app"
for uti in com.unity3d.meta com.unity3d.prefab com.unity3d.mat com.unity.document; do
  defaults write ~/Library/Preferences/org.sbarex.SourceCodeSyntaxHighlight uti-settings -dict-add "$uti" '<dict><key>syntax</key><string>yaml</string></dict>'
done

# tailscale: heal the LG U+ DS-Lite CGNAT route collision (see tailscale/TAILSCALE.md)
"$CONFIG/tailscale/cgnat-route.sh" install

# ntn (Notion CLI) — no brew formula; the npm build refuses `ntn update`. Auth is per-machine: `ntn login`
if [ -x "$HOME/.local/bin/ntn" ]; then
  "$HOME/.local/bin/ntn" update
else
  curl -fsSL https://ntn.dev | NTN_INSTALL_DIR="$HOME/.local/bin" bash
fi

