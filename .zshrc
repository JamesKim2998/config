# Init zsh.
export ZSH=~/.oh-my-zsh
export TERM="xterm-256color"
ZSH_THEME="mortalscumbag"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export EDITOR=/usr/local/bin/nvim

# Homebrew
HOMEBREW_NO_AUTO_UPDATE=1

source "$HOME/.zshrc_workspace" # Apply workspace config.
source "$HOME/.zshrc_alias" # Apply alias.
source "$HOME/.zshrc_utils" # Apply utils.
