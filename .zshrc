# Init zsh.
export ZSH=~/.oh-my-zsh
export TERM="xterm-256color"
ZSH_THEME="mortalscumbag"
plugins=(vi-mode git zsh-autosuggestions)
zstyle ':omz:update' mode auto # Automatic update without confirmation prompt.
source $ZSH/oh-my-zsh.sh

source "$HOME/.zshrc_alias" # Apply alias.
source "$HOME/.zshrc_utils" # Apply utils.


# nvim
export PATH="$PATH:/opt/homebrew/bin/nvim"
export EDITOR=/opt/homebrew/bin/nvim

# android
export PATH="$PATH:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools"

# dotnet
export PATH="$HOME/.dotnet:$PATH"

# java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/jameskim/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# autojump
[ -f "/opt/homebrew/etc/autojump.sh" ] && . "/opt/homebrew/etc/autojump.sh"

# Unity
MEOW_REPO="$HOME/Develop/meow-tower"
UNITY_VER=$(head -1 "$MEOW_REPO/ProjectSettings/ProjectVersion.txt" | cut -c18-)
UNITY_ROOT="/Applications/Unity/Hub/Editor/$UNITY_VER"
