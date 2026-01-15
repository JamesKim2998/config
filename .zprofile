# .zshenv - all shells (keep minimal, runs before path_helper)
# .zprofile - login shells (PATH, env vars - inherited by subshells)
# .zshrc - interactive shells (aliases, functions, prompt - not inherited)

# homebrew (baked from: /opt/homebrew/bin/brew shellenv)
BREW=/opt/homebrew
export HOMEBREW_PREFIX="$BREW"
export HOMEBREW_CELLAR="$BREW/Cellar"
export HOMEBREW_REPOSITORY="$BREW"
export PATH="$BREW/bin:$BREW/sbin:$PATH"
export MANPATH="$BREW/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$BREW/share/info:${INFOPATH:-}"
fpath=("$BREW/share/zsh/site-functions" $fpath)
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
export HOMEBREW_NO_ENV_HINTS=1

# editors
export EDITOR=$BREW/bin/nvim

# path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$BREW/opt/openjdk/bin:$PATH"
export PATH="$BREW/opt/trash-cli/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# dotnet
export DOTNET_ROOT="$HOME/.dotnet"

# claude code
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# fzf (Kanagawa colors)
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#2d4f67,bg:#1f1f28,spinner:#c8c093,hl:#c34043 \
  --color=fg:#dcd7ba,header:#c34043,info:#957fb8,pointer:#c8c093 \
  --color=marker:#7e9cd8,fg+:#dcd7ba,prompt:#957fb8,hl+:#e82424 \
  --color=selected-bg:#2d4f67 \
  --color=border:#727169,label:#dcd7ba"

# zoxide
export _ZO_FZF_OPTS='+e --height=40% --layout=reverse --border --no-sort'
