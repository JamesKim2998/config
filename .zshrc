# .zprofile - login shell (once per session): PATH, env vars
# .zshrc - interactive shell (every terminal): aliases, functions, completions, prompt

# zsh options
setopt AUTO_CD              # cd into directories by typing the path

# vi mode
bindkey -v
KEYTIMEOUT=1  # 10ms escape delay for instant mode switching

# zsh completions (skip audit, always use cache)
autoload -Uz compinit && compinit -C -u

# zsh-autosuggestions (ghost suggestions)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=512
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# claude code - run from nearest parent with CLAUDE.md
cc() {
  local orig="$PWD" dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/CLAUDE.md" ]]; then
      [[ "$dir" != "$orig" ]] && builtin cd "$dir"
      claude --model opus --dangerously-skip-permissions "$@"
      [[ "$dir" != "$orig" ]] && builtin cd "$orig" >/dev/null
      return
    fi
    dir="$(dirname "$dir")"
  done
  claude --model opus --dangerously-skip-permissions "$@"
}


# nvim
alias v="$EDITOR"
alias ve="$EDITOR $HOME/.config/nvim/init.lua"


# bun (cached completions)
_bun=~/.cache/bun.zsh
[[ -f $_bun && $_bun -nt $BUN_INSTALL/_bun ]] || cat "$BUN_INSTALL/_bun" > $_bun 2>/dev/null
[[ -f $_bun ]] && source $_bun


# fzf (cached)
_fzf=~/.cache/fzf.zsh
[[ -f $_fzf && $_fzf -nt $HOMEBREW_PREFIX/bin/fzf ]] || fzf --zsh > $_fzf
source $_fzf


# eza (modern ls replacement with icons and git integration)
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons --git --header'
alias la='eza -la --group-directories-first --icons --git --header'
alias lt='eza --tree --level 2 --icons'


# zoxide (cached)
_zoxide=~/.cache/zoxide.zsh
[[ -f $_zoxide && $_zoxide -nt $HOMEBREW_PREFIX/bin/zoxide ]] || zoxide init zsh > $_zoxide
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
[[ -f $_starship && $_starship -nt $HOMEBREW_PREFIX/bin/starship ]] || starship init zsh > $_starship
source $_starship


# kitty ssh (auto-reconnect in new windows/panes)
alias ssh="kitten ssh"

# SSH session setup
if [[ -n "$SSH_TTY" ]]; then
  alias pbcopy='~/.local/bin/osc52-copy'  # OSC 52: copy to local clipboard via terminal
  zshexit() { pwd > ~/.sv_last_dir }      # save cwd for sv() cd-on-exit
fi

# macmini
MACMINI_HOST=macmini.studioboxcat.com
MACMINI_USER=jameskim
MACMINI_SSH_KEY=~/.ssh/james-macmini
MACMINI_DEST=$MACMINI_USER@$MACMINI_HOST

# server SSH (Tokyo Night colors, cd sync)
sv() {
  kitten @ set-colors --match "id:$KITTY_WINDOW_ID" ~/.config/kitty/themes/tokyonight-window.conf
  ssh -i $MACMINI_SSH_KEY $MACMINI_DEST -t "cd '$PWD' 2>/dev/null; exec zsh"
  kitten @ set-colors --match "id:$KITTY_WINDOW_ID" --reset
  local d=$(/usr/bin/ssh -i $MACMINI_SSH_KEY $MACMINI_DEST cat ~/.sv_last_dir 2>/dev/null)
  [[ -d "$d" ]] && cd "$d"
}


# auto ls
autoload -U add-zsh-hook
_ls() { ls }
_ls_once() { ls; add-zsh-hook -d precmd _ls_once }
add-zsh-hook chpwd _ls      # on cd
add-zsh-hook precmd _ls_once                             # on new shell (once)


# aliases
alias g="lazygit"

