# select terminal emulator
if [[ -n $KITTY_WINDOW_ID ]]; then     # set by Kitty itself
  export TERM="xterm-kitty"
else
  export TERM="xterm-256color"
fi


# init zsh.
export ZSH=~/.oh-my-zsh
ZSH_THEME=""
plugins=(vi-mode git zsh-autosuggestions)
zstyle ':omz:update' mode disabled # disable auto update
source $ZSH/oh-my-zsh.sh

 
# brew
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
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


# fzf
source <(fzf --zsh)

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


# zoxide
export _ZO_FZF_OPTS='+e --height=40% --layout=reverse --border --no-sort'
eval "$(zoxide init zsh)"


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


# starship
eval "$(starship init zsh)"


# trash-cli
# https://github.com/andreafrancia/trash-cli
export PATH="/opt/homebrew/opt/trash-cli/bin:$PATH"


# auto ls
autoload -U add-zsh-hook
_ls() { ls }
_ls_once() { ls; add-zsh-hook -d precmd _ls_once }
add-zsh-hook chpwd _ls      # on cd
add-zsh-hook precmd _ls_once # on new shell (once)

