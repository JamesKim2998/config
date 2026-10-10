# Sourced before each Claude Code Bash command: settings.json's SessionStart hook appends it to
# $CLAUDE_ENV_FILE, the one env that outlasts the shell snapshot, whose PATH is Claude Code's own.
# https://code.claude.com/docs/en/hooks#persist-environment-variables
[[ :$PATH: == *":$HOME/Develop/config/.claude/bin:"* ]] || export PATH="$HOME/Develop/config/.claude/bin:$PATH"
