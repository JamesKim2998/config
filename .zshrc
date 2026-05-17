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


# just (lazy completions — load on first TAB, not at shell startup)
# `just --completions zsh` is a trampoline that re-runs `just` on source; we cache the inner clap dispatcher.
_just() {
  local cache=~/.cache/just.zsh
  [[ -f $cache && $cache -nt $commands[just] ]] || JUST_COMPLETE=zsh just > $cache
  unfunction _just
  source $cache  # redefines _clap_dynamic_completer_just and re-binds compdef for `just`
  _clap_dynamic_completer_just "$@"
}
compdef _just just


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
alias ze='cd "$CONFIG_REPO" && $EDITOR .zshrc'
# lazygit wrapper: cd to repo/worktree on switch (ctrl+r, branches `w`).
# TMPDIR (vs ~/.cache) — lazygit's WriteFile doesn't mkdir parents.
g() {
  export LAZYGIT_NEW_DIR_FILE="${TMPDIR:-/tmp}/lazygit-newdir"
  lazygit "$@"
  if [[ -f $LAZYGIT_NEW_DIR_FILE ]]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    command rm -f -- "$LAZYGIT_NEW_DIR_FILE"
  fi
}
alias gr='cd "$(git rev-parse --show-toplevel)"'
alias todo="(cd \"$MEOW_ROOT/todo/\"; $EDITOR todo.md)"
# NB: local var named `wt` (not `path`) — zsh ties lowercase `path` to $PATH;
# `local path` empties PATH inside the function and breaks `git`/`awk` lookup.
cdw() {
  local target="$1" wt
  [[ -z "$target" ]] && { git worktree list; return; }
  wt=$(git worktree list --porcelain | awk -v t="$target" '
    /^worktree / { p = $2 }
    /^branch /   { br = $2; sub(/^refs\/heads\//, "", br)
                   base = p; sub(/.*\//, "", base)
                   if (br == t || base == t) { print p; exit } }')
  [[ -n "$wt" ]] || { echo "cdw: no worktree matching '$target'" >&2; return 1; }
  cd "$wt"
}


# llm (cd to CLAUDE.md root if found)
ai() {
  local dir="$PWD"
  while [[ "$dir" != "/" && ! -f "$dir/CLAUDE.md" ]]; do
    dir="$(dirname "$dir")"
  done
  [[ "$dir" == "/" && ! -f /CLAUDE.md ]] && dir="$PWD"
  (
    [[ "$dir" != "$PWD" ]] && builtin cd "$dir" >/dev/null
    claude --dangerously-skip-permissions "$@"
    # codex --dangerously-bypass-approvals-and-sandbox "$@"
  )
}

ai-mt() { (cd "$MEOW_CLIENT" && claude --dangerously-skip-permissions "$@") }
ai-tb() { (cd "$MEOW_TOOLBOX" && claude --dangerously-skip-permissions "$@") }
ai-cf() { (cd "$CONFIG_REPO" && claude --dangerously-skip-permissions "$@") }

alias aiu="claude update"


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


# `wt go <TAB>` picker. `wt ls` already filters held-only and drops the
# STATE/NAME columns from `worktree-pool ls`, so column 1 is the held slot
# name (ID == NAME post-rename). Skip the 2-line header/separator.
# `--bare` skips per-slot `git status --porcelain` — saves ~1s × N held slots
# on cold Unity caches; TAB only needs the names.
# Tested in `diagnostics/wt-completion.test.ts`.
_wt_go_pick() {
  wt ls --bare 2>/dev/null \
    | awk 'NR>2 {print $1}' \
    | fzf --height=40% --reverse --no-multi --header='wt go: pick slot to resume'
}

# fzf-driven TAB completion: dispatches on the current LBUFFER pattern;
# unmatched buffers fall through to the default completer.
_fzf_tab_dispatch() {
  if [[ "$LBUFFER" =~ '^[[:space:]]*cdw([[:space:]]+[^[:space:]]*)?$' ]]; then
    local sel
    sel=$(git worktree list 2>/dev/null | awk '{
        name=""
        for (i=NF; i>=1; i--) if ($i ~ /^\[.*\]$/) { name=substr($i,2,length($i)-2); break }
        if (name == "") next   # skip detached-HEAD (idle worktree-pool slots etc.)
        if (length(name) > 32) name = substr(name, 1, 32)
        printf "%-32s  %s\n", name, $0
      }' | fzf --height=40% --reverse --no-multi | awk '{print $1}')
    [[ -n "$sel" ]] && LBUFFER="${LBUFFER%%cdw*}cdw $sel"
    zle reset-prompt
  elif [[ "$LBUFFER" =~ '^([[:space:]]*wt([[:space:]]+(--pool|-p)[[:space:]]+[^[:space:]]+)?[[:space:]]+go)([[:space:]]+[^[:space:]]*)?$' ]]; then
    # Held slots only — fresh names are typed, not picked. Pool auto-resolves from cwd inside `wt ls`.
    local prefix="${match[1]}" sel
    sel=$(_wt_go_pick)
    [[ -n "$sel" ]] && LBUFFER="$prefix $sel"
    zle reset-prompt
  else
    zle expand-or-complete
  fi
}
zle -N _fzf_tab_dispatch
bindkey '^I' _fzf_tab_dispatch
