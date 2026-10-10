# Sourced before each Claude Code Bash command: settings.json's SessionStart hook appends it to
# $CLAUDE_ENV_FILE, the one env that outlasts the shell snapshot, whose PATH is Claude Code's own.
# https://code.claude.com/docs/en/hooks#persist-environment-variables
[[ :$PATH: == *":$HOME/Develop/config/.claude/bin:"* ]] || export PATH="$HOME/Develop/config/.claude/bin:$PATH"

# A boxcat pool slot's own CLIs, from the nearest `.host-tools/bin` above the working directory, ahead
# of the host's (`worktree-pool.md` (boxcat), Tools); one left on PATH from another tree goes first.
# Split by hand: zsh doesn't word-split an unquoted $PATH.
_rest=$PATH: _np= _d=$PWD
while [ -n "$_rest" ]; do
  _e=${_rest%%:*} _rest=${_rest#*:}
  case $_e in */.host-tools/bin) ;; *) _np=${_np:+$_np:}$_e ;; esac
done
while [ -n "$_d" ] && [ ! -d "$_d/.host-tools/bin" ]; do _d=${_d%/*}; done
export PATH=${_d:+$_d/.host-tools/bin:}$_np
unset _rest _e _np _d
