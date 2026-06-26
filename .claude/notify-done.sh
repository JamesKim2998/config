#!/usr/bin/env bash
# Claude Code Stop-hook notifier — clickable macOS banner titled with the session name
# (last `ai-title` in the transcript; else "Task complete"). Clicking it focuses the
# terminal/IDE the session launched from.
#
# Why alerter, not terminal-notifier: the latter's NSUserNotification click callbacks
# stopped firing on macOS 14+. alerter blocks and prints the click result on stdout.
# Header icon (Claude logo): --sender points at the icon-only helper bundle
# com.studioboxcat.claude-notify (ClaudeSender.app, registered by setup.sh) — --app-icon
# can't override the header icon, hence the dedicated bundle.

SENDER="com.studioboxcat.claude-notify"
TIMEOUT=120                       # seconds the banner stays clickable before auto-closing

in=$(cat)
transcript=$(printf '%s' "$in" | jq -r '.transcript_path // empty')

name=""
[ -f "$transcript" ] && name=$(grep '"type":"ai-title"' "$transcript" 2>/dev/null | tail -1 | jq -r '.aiTitle // empty')
[ -z "$name" ] && name="Task complete"

# Walk parents up to the first .app bundle; echo its bundle path.
origin_app() {
  local pid=$PPID ppid comm depth=0
  while [ -n "$pid" ] && [ "$pid" -gt 1 ] && [ "$depth" -lt 20 ]; do
    read -r ppid comm < <(ps -o ppid=,comm= -p "$pid" 2>/dev/null)
    [ -z "$ppid" ] && break
    case "$comm" in
      */*.app/Contents/*)         # outermost .app wins (VS Code nests Code Helper.app)
        printf '%s.app\n' "${comm%%.app/Contents/*}"; return ;;
    esac
    pid=$ppid; depth=$((depth+1))
  done
}

# Render an app bundle's icon to a cached PNG keyed by $id; echo its path (nothing on failure).
app_icon_png() {
  local app=$1 id=$2 icf icns cache png
  [ -d "$app" ] && [ -n "$id" ] || return
  icf=$(/usr/libexec/PlistBuddy -c "Print CFBundleIconFile" "$app/Contents/Info.plist" 2>/dev/null)
  [ -n "$icf" ] || return
  icns="$app/Contents/Resources/${icf%.icns}.icns"
  [ -f "$icns" ] || return
  cache="$HOME/.cache/claude-notify"; mkdir -p "$cache"
  png="$cache/$id.png"
  [ -f "$png" ] || sips -s format png -Z 128 "$icns" --out "$png" >/dev/null 2>&1 || return
  printf '%s\n' "$png"
}

app=$(origin_app)
origin_id=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$app/Contents/Info.plist" 2>/dev/null)
img=$(app_icon_png "$app" "$origin_id")

args=(--title "Claude Code" --message "$name" --sound Glass --sender "$SENDER" --timeout "$TIMEOUT")
[ -n "$img" ] && args+=(--content-image "$img")

# Block in the background waiting for the click, then raise the origin app.
(
  res=$(alerter "${args[@]}" 2>/dev/null)
  case "$res" in
    @CONTENTCLICKED|@ACTIONCLICKED)   # focus origin app (System Events, per unity-launcher's focus_process)
      [ -n "$origin_id" ] && osascript -e \
        "tell application \"System Events\" to set frontmost of (first process whose bundle identifier is \"$origin_id\") to true" \
        >/dev/null 2>&1 ;;
  esac
) &
