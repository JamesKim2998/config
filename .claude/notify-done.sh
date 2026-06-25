#!/usr/bin/env bash
# Claude Code Stop-hook notifier — macOS banner titled with the current session name.
# stdin: Stop-hook JSON. The session name is the last `ai-title` line in the
# transcript (Claude Code internal transcript format). Falls back to "Task complete"
# for sessions that have no title yet.

in=$(cat)
transcript=$(printf '%s' "$in" | jq -r '.transcript_path // empty')

name=""
[ -f "$transcript" ] && name=$(grep '"type":"ai-title"' "$transcript" 2>/dev/null | tail -1 | jq -r '.aiTitle // empty')
name=${name//\"/}                 # strip quotes so they can't break the AppleScript literal
[ -z "$name" ] && name="Task complete"

osascript -e "display notification \"$name\" with title \"Claude Code\" sound name \"Glass\"" >/dev/null 2>&1 &
