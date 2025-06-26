# init zsh.
export ZSH=~/.oh-my-zsh
export TERM="xterm-kitty"
ZSH_THEME=""
plugins=(vi-mode git zsh-autosuggestions)
zstyle ':omz:update' mode disabled # disable auto update
source $ZSH/oh-my-zsh.sh

# common alias
alias y='yazi'

# brew
export PATH="$PATH:/opt/homebrew/bin"

# nvim
export EDITOR=/opt/homebrew/bin/nvim
alias v="$EDITOR"
alias ve="$EDITOR $HOME/.config/nvim/init.vim"

# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOME/.dotnet"

# android & java
export PATH="$PATH:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init zsh)"

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun" # bun completions
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# starship
eval "$(starship init zsh)"

