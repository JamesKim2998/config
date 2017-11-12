# zsh/plugin
export ZSH=~/.oh-my-zsh
ZSH_THEME="mortalscumbag"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export EDITOR="nvim"

alias v=nvim
alias ze="v ~/.zshrc"
alias zs="source ~/.zshrc"
alias gup="git pull --rebase --autostash --prune"
alias dev="cd ~/Develop"
alias dn="cd ~/Downloads"

export WORK="kimjames@172.24.0.186"
alias work="ssh $WORK"

function chpwd() {
    emulate -L zsh
    ls
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# cdf - cd into the directory of the selected file
cdf() {
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

# fshow - git commit browser
function fshow {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# git breeze
[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"

source /usr/local/etc/profile.d/z.sh

source ~/.zshrc_workplace

