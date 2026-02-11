# .zshenv - ALL shells (login, interactive, scripts, subshells)
# .zshrc - interactive shells only (aliases, functions, prompt)

# zsh options
setopt AUTO_CD              # cd into directories by typing the path

# vi mode
bindkey -v
KEYTIMEOUT=1  # 10ms escape delay for instant mode switching

# Restore readline shortcuts in vi mode
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# zsh completions (skip audit, use compiled cache)
autoload -Uz compinit && compinit -C -u
[[ ~/.zcompdump.zwc -ot ~/.zcompdump ]] && zcompile ~/.zcompdump &!

# zsh-autosuggestions (ghost suggestions)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=512
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh


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

# fuzzy edit
fe() {
  local file
  file=$(fzf --preview 'bat --color=always {}') && $EDITOR "$file"
}


# eza (modern ls replacement with icons and git integration)
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons --git --header'
alias la='eza -la --group-directories-first --icons --git --header'
alias lt='eza --tree --level 2 --icons'


# zoxide (cached)
_zoxide=~/.cache/zoxide.zsh
[[ -f $_zoxide && $_zoxide -nt $HOMEBREW_PREFIX/bin/zoxide ]] || zoxide init zsh > $_zoxide
source $_zoxide
zi() { __zoxide_zi "$PWD" }  # scope to cwd


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
# PROMPT2 = continuation prompt for multi-line commands (unclosed quotes, loops, etc.)
# Patched to static '∙' to avoid 7ms sync `starship prompt --continuation` call on init
_starship=~/.cache/starship.zsh
if [[ ! -f $_starship || $HOMEBREW_PREFIX/bin/starship -nt $_starship ]]; then
  starship init zsh | sed "s|^PROMPT2=.*|PROMPT2='%F{240}∙%f '|" > $_starship
fi
source $_starship


# auto ls
autoload -U add-zsh-hook
_ls() { ls }
_ls_once() { ls; add-zsh-hook -d precmd _ls_once }
add-zsh-hook chpwd _ls      # on cd
add-zsh-hook precmd _ls_once                             # on new shell (once)


# copy paths
alias cpwd='pwd | pbcopy'
cpr() {
  local root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not in a git repo" >&2; return 1; }
  echo "$root" | pbcopy
}


# aliases
alias restart='exec zsh'
alias ze="$EDITOR ~/.zshrc"
alias g="lazygit"
alias todo="(cd \"$MEOW_ROOT/todo/\"; $EDITOR todo.md)"


# llm (cd to AGENTS.md root if found)
ai() {
  local dir="$PWD"
  while [[ "$dir" != "/" && ! -f "$dir/AGENTS.md" ]]; do
    dir="$(dirname "$dir")"
  done
  (
    [[ "$dir" != "$PWD" ]] && builtin cd "$dir" >/dev/null
    claude --model opus --dangerously-skip-permissions "$@"
    # codex --dangerously-bypass-approvals-and-sandbox "$@"
  )
}
alias aiu="claude update"
# alias aiu="bun update -g @openai/codex --latest"


# kitty ssh (auto-reconnect in new windows/panes)
alias kssh="kitten ssh"

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
  kssh macmini -t "cd '$PWD' 2>/dev/null; exec zsh -l"
  kitten @ set-colors --match "id:$KITTY_WINDOW_ID" --reset
  local d=$(ssh macmini cat ~/.sv_last_dir 2>/dev/null)
  [[ -d "$d" ]] && cd "$d"
}


