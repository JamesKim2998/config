export ZSH=/Users/kimjames/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git)

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
source $ZSH/oh-my-zsh.sh

alias zshedit="vi ~/.zshrc"
alias zshso="source ~/.zshrc"
alias mstcd="~/Develop/master"
alias msto="open -a /Applications/AppCode.app ~/Develop/master/OBXCodeTrunk/OvenbreakX/OvenbreakX.xcodeproj"

function chpwd() {
    emulate -L zsh
    ls -a
}

