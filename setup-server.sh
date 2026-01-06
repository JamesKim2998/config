#!/bin/bash
# Server-specific setup (run after setup.sh)

set -e

CONFIG=$HOME/Develop/config
XDG_CONFIG=$HOME/.config
ZSHENV=$HOME/.zshenv
LAUNCH_AGENTS=$HOME/Library/LaunchAgents

# Ensure .zshenv exists
touch "$ZSHENV"

# Add env vars to .zshenv
append_if_missing() {
  grep -q "$1" "$ZSHENV" || { echo "$2" >> "$ZSHENV"; echo "Added $1 to $ZSHENV"; }
}

append_if_missing 'THEME_NVIM' 'export THEME_NVIM="tokyonight-night"'
append_if_missing 'STARSHIP_CONFIG' "export STARSHIP_CONFIG=$XDG_CONFIG/starship-server.toml"
append_if_missing 'BAT_THEME' 'export BAT_THEME="tokyonight"'

# Set delta syntax theme
git config --file ~/.gitconfig.local delta.syntax-theme tokyonight

# Generate Tokyo Night starship config
sd 'palette = "kanagawa"' 'palette = "tokyonight"' < "$XDG_CONFIG/starship.toml" > "$XDG_CONFIG/starship-server.toml"
echo "Created starship-server.toml"

# Switch yazi theme to Tokyo Night
ln -sf theme-tokyonight.toml "$XDG_CONFIG/yazi/theme.toml"
echo "Switched yazi theme to Tokyo Night"

# Rebuild bat cache (for custom themes)
bat cache --build
echo "Rebuilt bat cache"

# GitHub mirror sync (30-second interval)
MIRROR_PLIST=$CONFIG/github-mirror/com.boxcat.github-mirror.plist
mkdir -p ~/Develop/github-mirror
chmod +x "$CONFIG/github-mirror/sync.sh"
cp "$MIRROR_PLIST" "$LAUNCH_AGENTS/"
launchctl unload "$LAUNCH_AGENTS/com.boxcat.github-mirror.plist" 2>/dev/null || true
launchctl load "$LAUNCH_AGENTS/com.boxcat.github-mirror.plist"
echo "Installed GitHub mirror LaunchAgent"

echo "Done!"
