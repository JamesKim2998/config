BREW=/opt/homebrew

# zsh options
setopt AUTO_CD              # cd into directories by typing the path

# vi mode
bindkey -v
KEYTIMEOUT=1  # 10ms escape delay for instant mode switching

# zsh completions (rebuild cache daily)
autoload -Uz compinit
[[ -n ~/.zcompdump(#qN.mh+24) ]] && compinit || compinit -C

# zsh-autosuggestions (ghost suggestions)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=512
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source $BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh

 
# brew
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
export HOMEBREW_NO_ENV_HINTS=1
export PATH="$BREW/bin:$HOME/.local/bin:$PATH"

# claude code
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1


# nvim
export EDITOR=$BREW/bin/nvim
alias v="$EDITOR"
alias ve="$EDITOR $HOME/.config/nvim/init.lua"


# rust
export PATH="$HOME/.cargo/bin:$PATH"


# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOME/.dotnet"


# haxe
export HAXE_STD_PATH="$BREW/lib/haxe/std"


# android & java
export PATH="$PATH:$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools"
export PATH="$BREW/opt/openjdk/bin:$PATH"


# bun (cached completions)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
_bun=~/.cache/bun.zsh
[[ -f $_bun && $_bun -nt $BUN_INSTALL/_bun ]] || cat "$BUN_INSTALL/_bun" > $_bun 2>/dev/null
[[ -f $_bun ]] && source $_bun


# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# fzf (cached)
_fzf=~/.cache/fzf.zsh
[[ -f $_fzf && $_fzf -nt $BREW/bin/fzf ]] || fzf --zsh > $_fzf
source $_fzf

# Kanagawa fzf colors (manually mapped from palette by Claude)
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#2d4f67,bg:#1f1f28,spinner:#c8c093,hl:#c34043 \
  --color=fg:#dcd7ba,header:#c34043,info:#957fb8,pointer:#c8c093 \
  --color=marker:#7e9cd8,fg+:#dcd7ba,prompt:#957fb8,hl+:#e82424 \
  --color=selected-bg:#2d4f67 \
  --color=border:#727169,label:#dcd7ba"


# eza (modern ls replacement with icons and git integration)
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons --git --header'
alias la='eza -la --group-directories-first --icons --git --header'
alias lt='eza --tree --level 2 --icons'


# zoxide (cached)
export _ZO_FZF_OPTS='+e --height=40% --layout=reverse --border --no-sort'
_zoxide=~/.cache/zoxide.zsh
[[ -f $_zoxide && $_zoxide -nt $BREW/bin/zoxide ]] || zoxide init zsh > $_zoxide
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
[[ -f $_starship && $_starship -nt $BREW/bin/starship ]] || starship init zsh > $_starship
source $_starship


# trash-cli
# https://github.com/andreafrancia/trash-cli
export PATH="$BREW/opt/trash-cli/bin:$PATH"


# kitty ssh (auto-reconnect in new windows/panes)
alias ssh="kitten ssh"

# server mosh (low-latency SSH with tmux for mouse scrolling)
sv() {
  # Change window colors to Tokyo Night (keeps border unchanged)
  kitten @ set-colors --match "id:$KITTY_WINDOW_ID" ~/.config/kitty/themes/tokyonight-window.conf

  # cd to same directory on server, attach or create tmux session
  mosh --ssh="ssh -i ~/.ssh/james-macmini" jameskim@192.168.219.122 -- sh -c "cd '$PWD' 2>/dev/null; tmux new -A -s main"

  # Restore on disconnect
  kitten @ set-colors --match "id:$KITTY_WINDOW_ID" --reset

  # cd to same directory locally (read saved path from server)
  local remote_dir=$(ssh -i ~/.ssh/james-macmini jameskim@192.168.219.122 "cat ~/.sv_last_dir 2>/dev/null")
  [[ -n "$remote_dir" && -d "$remote_dir" ]] && cd "$remote_dir"
}


# auto ls
autoload -U add-zsh-hook
_ls() { ls }
_ls_once() { ls; add-zsh-hook -d precmd _ls_once }
add-zsh-hook chpwd _ls      # on cd
add-zsh-hook precmd _ls_once                             # on new shell (once)


# aliases
alias g="lazygit"

