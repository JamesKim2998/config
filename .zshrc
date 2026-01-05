# select terminal emulator
if [[ -n $KITTY_WINDOW_ID ]]; then     # set by Kitty itself
  export TERM="xterm-kitty"
else
  export TERM="xterm-256color"
fi


# vi mode
bindkey -v

# atuin (shell history & suggestions)
_atuin=~/.cache/atuin.zsh
[[ -f $_atuin && $_atuin -nt /opt/homebrew/bin/atuin ]] || atuin init zsh > $_atuin
source $_atuin

 
# brew
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
export HOMEBREW_NO_ENV_HINTS=1
export PATH="$HOME/.local/bin:$PATH:/opt/homebrew/bin"


# nvim
export EDITOR=/opt/homebrew/bin/nvim
alias v="$EDITOR"
alias ve="$EDITOR $HOME/.config/nvim/init.vim"


# rust
export PATH="$HOME/.cargo/bin:$PATH"


# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOME/.dotnet"


# haxe
export HAXE_STD_PATH="/opt/homebrew/lib/haxe/std"


# android & java
export PATH="$PATH:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"


# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun" # bun completions
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# pnpm
export PNPM_HOME="/Users/jameskim/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# fzf (cached)
_fzf=~/.cache/fzf.zsh
[[ -f $_fzf && $_fzf -nt /opt/homebrew/bin/fzf ]] || fzf --zsh > $_fzf
source $_fzf

# https://github.com/catppuccin/fzf/blob/main/themes/catppuccin-fzf-mocha.sh
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
  --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
  --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
  --color=selected-bg:#45475A \
  --color=border:#313244,label:#CDD6F4"


# eza (modern ls replacement with icons and git integration)
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons --git --header'
alias la='eza -la --group-directories-first --icons --git --header'
alias lt='eza --tree --level 2 --icons'


# zoxide (cached)
export _ZO_FZF_OPTS='+e --height=40% --layout=reverse --border --no-sort'
_zoxide=~/.cache/zoxide.zsh
[[ -f $_zoxide && $_zoxide -nt /opt/homebrew/bin/zoxide ]] || zoxide init zsh > $_zoxide
source $_zoxide


# yazi
# automatically cd to the last used directory when running yazi
# https://yazi-rs.github.io/docs/quick-start/
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}


# starship (cached)
_starship=~/.cache/starship.zsh
[[ -f $_starship && $_starship -nt /opt/homebrew/bin/starship ]] || starship init zsh > $_starship
source $_starship


# trash-cli
# https://github.com/andreafrancia/trash-cli
export PATH="/opt/homebrew/opt/trash-cli/bin:$PATH"


# kitty ssh (auto-reconnect in new windows/panes)
alias ssh="kitten ssh"

# server mosh (low-latency SSH)
sv() { mosh --ssh="ssh -i ~/.ssh/james-macmini" jameskim@192.168.219.122 "$@" }


# auto ls
autoload -U add-zsh-hook
_ls() { ls }
_ls_once() { ls; add-zsh-hook -d precmd _ls_once }
add-zsh-hook chpwd _ls      # on cd
add-zsh-hook precmd _ls_once # on new shell (once)

