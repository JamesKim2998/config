#! /bin/bash

UNITY_APP=/Applications/Unity/Unity.app/Contents/MacOS/Unity
UNITY_PROJ=$HOME/Develop/meow-tower

# check if unity project open
# process looks like this
IS_OPEN=$(pgrep -f "Unity -projectPath $UNITY_PROJ")

# if unity project is not open, open it
if [ -z "$IS_OPEN" ]; then
    pkill CodePatcherCLI
    pkill HotReload
    open -a $UNITY_APP -n --args -projectPath "$UNITY_PROJ"
# else focus on unity project
else
    osascript <<EOF
tell application "System Events"
    set frontmost of the first process whose name contains "Unity" to true
end tell
EOF
fi

