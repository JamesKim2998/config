#!/bin/bash
# Sync all GitHub mirror repos from origin (GitHub)
for repo in ~/Develop/github-mirror/*.git; do
    [ -d "$repo" ] && git -C "$repo" fetch --all -q 2>/dev/null
done
