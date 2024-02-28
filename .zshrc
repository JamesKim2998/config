# Init zsh.
export ZSH=~/.oh-my-zsh
export TERM="xterm-256color"
ZSH_THEME="mortalscumbag"
plugins=(vi-mode git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

export PATH="$PATH:/opt/homebrew/bin/nvim"
export EDITOR=/opt/homebrew/bin/nvim

source "$HOME/.zshrc_alias" # Apply alias.
source "$HOME/.zshrc_utils" # Apply utils.


# Install j.
[ -f "/opt/homebrew/etc/autojump.sh" ] && . "/opt/homebrew/etc/autojump.sh"


# Install scm_breeze.
[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"


# pnpm
export PNPM_HOME="/Users/jameskim/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# Unity
UNITY="/Applications/Unity/Unity.app"
export PATH="$UNITY/Contents/MacOS/Unity/PlaybackEngines/AndroidPlayer/SDK/platform-tools:$PATH"
