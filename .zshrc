export ZSH=/Users/kimjames/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git)

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
source $ZSH/oh-my-zsh.sh

alias zshedit="vi ~/.zshrc"
alias zshso="source ~/.zshrc"

function chpwd() {
    emulate -L zsh
    ls
}

