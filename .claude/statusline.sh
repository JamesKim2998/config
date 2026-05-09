#!/bin/bash
# Claude Code status line: repo  branch  status  vim
# Input contract: https://code.claude.com/docs/en/statusline#available-data
# Pair with `statusLine.hideVimModeIndicator: true` so the built-in `-- INSERT --`
# doesn't double up.

set -uo pipefail

IFS=$'\t' read -r cwd vim_mode session_id < <(
  jq -r '[.workspace.current_dir // .cwd // "", .vim.mode // "", .session_id // "default"] | @tsv'
)

RST=$'\033[0m'
BOLD=$'\033[1m'
FG_CY=$'\033[36m'
FG_GR=$'\033[32m'
FG_YL=$'\033[33m'
FG_RD=$'\033[31m'

dir_name="${cwd##*/}"
[[ -z "$dir_name" ]] && dir_name='~'

# Repo name comes from `remote.origin.url` (last path segment, `.git` stripped) so
# worktrees show the parent repo instead of the branch-named worktree dir. Falls
# back to dir name for repos without a remote or non-git dirs.
# git is the slow segment — cache per (session, cwd) for 2s to absorb rapid vim
# toggles. cwd in the key matters because `wt`/`cdw` switch repos within a session.
repo_name="$dir_name"
git_seg=''
if [[ -n "$cwd" ]]; then
  cache="/tmp/cc-statusline-${session_id}${cwd//\//_}"
  use_cache=0
  if [[ -f "$cache" ]]; then
    mtime=$(stat -f %m "$cache" 2>/dev/null || stat -c %Y "$cache" 2>/dev/null || echo 0)
    (( $(date +%s) - mtime < 2 )) && use_cache=1
  fi

  if (( use_cache )); then
    IFS=$'\t' read -r repo_name git_seg <"$cache" || :
  elif git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    remote=$(git -C "$cwd" config --get remote.origin.url 2>/dev/null)
    if [[ -n "$remote" ]]; then
      r="${remote##*/}"
      repo_name="${r%.git}"
    fi

    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
          || git -C "$cwd" rev-parse --short HEAD 2>/dev/null \
          || echo '?')

    porcelain=$(git -C "$cwd" status --porcelain=v1 2>/dev/null)
    staged=0; dirty=0
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      x=${line:0:1}; y=${line:1:1}
      [[ "$x" != ' ' && "$x" != '?' ]] && ((staged++))
      [[ "$y" != ' ' ]] && ((dirty++))
    done <<<"$porcelain"

    ahead=0; behind=0
    if git -C "$cwd" rev-parse --verify --quiet '@{upstream}' >/dev/null 2>&1; then
      counts=$(git -C "$cwd" rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null) || counts=''
      if [[ "$counts" =~ ^([0-9]+)[[:space:]]+([0-9]+)$ ]]; then
        ahead=${BASH_REMATCH[1]}
        behind=${BASH_REMATCH[2]}
      fi
    fi

    # nf-pl-branch (U+E0A0) — needs a Nerd Font terminal.
    seg="${FG_CY} ${branch}${RST}"
    if (( dirty == 0 && staged == 0 && ahead == 0 && behind == 0 )); then
      seg+=" ${FG_GR}✓${RST}"
    else
      (( dirty  > 0 )) && seg+=" ${FG_YL}●${dirty}${RST}"
      (( staged > 0 )) && seg+=" ${FG_GR}✚${staged}${RST}"
      (( ahead  > 0 )) && seg+=" ${FG_CY}⇡${ahead}${RST}"
      (( behind > 0 )) && seg+=" ${FG_RD}⇣${behind}${RST}"
    fi

    git_seg="$seg"
    # atomic write so concurrent readers never see partial ANSI.
    printf '%s\t%s' "$repo_name" "$git_seg" >"${cache}.tmp" 2>/dev/null \
      && mv -f "${cache}.tmp" "$cache" 2>/dev/null
  fi
fi

repo_seg="${BOLD}${repo_name}${RST}"

case "$vim_mode" in
  NORMAL)        vim_seg=$'\033[1;37;44m N \033[0m' ;;
  INSERT)        vim_seg=$'\033[1;30;42m I \033[0m' ;;
  VISUAL)        vim_seg=$'\033[1;37;45m V \033[0m' ;;
  "VISUAL LINE") vim_seg=$'\033[1;37;45m L \033[0m' ;;
  *)             vim_seg='' ;;
esac

out="$repo_seg"
[[ -n "$git_seg" ]] && out+="  $git_seg"
[[ -n "$vim_seg" ]] && out+="  $vim_seg"
printf '%s\n' "$out"
