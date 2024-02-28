#! /bin/bash

UNITY_APP=/Applications/Unity/Unity.app/Contents/MacOS/Unity
UNITY_PROJ=$HOME/Develop/meow-tower

# check if unity project open
# process looks like this
# /../Unity.app/Contents/MacOS/Unity -projectpath $UNITY_PROJ
IS_OPEN=$(pgrep -f "Unity -projectpath $UNITY_PROJ")

# if unity project is not open, open it
if [ -z "$IS_OPEN" ]; then
    pkill CodePatcherCLI
    pkill HotReload
    PATH="/opt/homebrew/bin:$PATH" "$UNITY_APP" -projectpath "$UNITY_PROJ"
# else focus on unity project
else
    osascript -e "tell application \"Unity\" to activate"
fi

