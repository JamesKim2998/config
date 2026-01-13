#!/bin/zsh
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
  nvim `# editor` \
  fzf rg fd `# search & find` \
  bat jq yq sd glow miller `# file viewing & data processing` \
  eza zoxide yazi `# file navigation & listing` \
  mediainfo `# yazi previews` \
  clipboard procs httpie wget `# system utilities` \
  7-zip ouch `# compression & archives` \
  imagemagick ffmpeg `# media processing` \
  lazygit delta git-lfs gh copilot `# git tools` \
  lua rust go node oven-sh/bun/bun dotnet `# languages & runtimes` \
  awscli `# cloud & cli tools` \
  just starship shellcheck zsh-autosuggestions `# shell tools`

brew_install --cask \
  kitty `# terminal emulator` \
  hammerspoon `# macOS automation` \
  libreoffice docker font-hack-nerd-font \
  tailscale `# mesh VPN for stable Mac Mini access`

# claude code
mkdir -p ~/.claude
ln -sf "$CONFIG/.claude/CLAUDE.md" ~/.claude/CLAUDE.md

# shell
touch ~/.hushlogin
ln -sf "$CONFIG/.zshrc" ~/.zshrc
ln -sf "$CONFIG/starship.toml" "$XDG_CONFIG/starship.toml"
ln -sf "$CONFIG/.ripgreprc" ~/.ripgreprc

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
# Copy manually: cp ~/Develop/config/karabiner.json ~/.config/karabiner/karabiner.json
# mkdir -p "$XDG_CONFIG/karabiner"
# ln -sf "$CONFIG/karabiner.json" "$XDG_CONFIG/karabiner/karabiner.json"

# hammerspoon
rm -rf ~/.hammerspoon
ln -s "$CONFIG/.hammerspoon" ~/.hammerspoon

# vscode
mkdir -p "$APP_SUPPORT/Code/User"
ln -sf "$CONFIG/.vscode/settings.json" "$APP_SUPPORT/Code/User/settings.json"

# cargo tools
cargo install stylua selene

