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
export PATH="$PATH:/opt/homebrew/bin"

# nvim
export EDITOR=/opt/homebrew/bin/nvim
alias v="$EDITOR"
alias ve="$EDITOR $HOME/.config/nvim/init.vim"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOME/.dotnet"

# android & java
export PATH="$PATH:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun" # bun completions
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fzf
source <(fzf --zsh)

# https://github.com/catppuccin/fzf/blob/main/themes/catppuccin-fzf-mocha.sh
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"

# lsd
alias ls='lsd --group-dirs first' # compact overview
alias ll='lsd -alh --date relative --group-dirs first' # detailed, all-files view (sizes & ages stay human-readable)
alias lt='lsd --tree --depth 2' # quick two-level directory tree

# zoxide
eval "$(zoxide init zsh)"

# yazi
# automatically cd to the last used directory when running yazi
# https://yazi-rs.github.io/docs/quick-start/
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# starship
eval "$(starship init zsh)"

