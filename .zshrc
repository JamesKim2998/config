# init zsh.
export ZSH=~/.oh-my-zsh
export TERM="xterm-kitty"
ZSH_THEME="mortalscumbag"
plugins=(vi-mode git zsh-autosuggestions)
zstyle ':omz:update' mode auto # Automatic update without confirmation prompt.
source $ZSH/oh-my-zsh.sh

# common alias
alias dev="cd $HOME/Develop"

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

# jetbrains
rd() {
  nohup /Applications/Rider.app/Contents/MacOS/Rider "$@" > /dev/null 2>&1
}
wt() {
  nohup /Applications/WebStorm.app/Contents/MacOS/WebStorm "$@" > /dev/null 2>&1
}

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun" # bun completions
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

