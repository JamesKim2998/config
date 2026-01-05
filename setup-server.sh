#!/bin/bash
# Server-specific setup (run after setup.sh)

set -e

CONFIG_DIR=~/.config
ZSHENV=~/.zshenv

# Ensure .zshenv exists
touch "$ZSHENV"

# Add env vars to .zshenv
append_if_missing() {
  grep -q "$1" "$ZSHENV" || { echo "$2" >> "$ZSHENV"; echo "Added $1 to $ZSHENV"; }
}

append_if_missing 'THEME_NVIM' 'export THEME_NVIM="tokyonight-night"'
append_if_missing 'STARSHIP_CONFIG' "export STARSHIP_CONFIG=$CONFIG_DIR/starship-server.toml"
append_if_missing 'BAT_THEME' 'export BAT_THEME="tokyonight"'

# Set delta syntax theme
git config --file ~/.gitconfig.local delta.syntax-theme tokyonight

# Generate Tokyo Night starship config
sd 'palette = "kanagawa"' 'palette = "tokyonight"' < "$CONFIG_DIR/starship.toml" > "$CONFIG_DIR/starship-server.toml"
echo "Created starship-server.toml"

# Switch yazi theme to Tokyo Night
ln -sf theme-tokyonight.toml "$CONFIG_DIR/yazi/theme.toml"
echo "Switched yazi theme to Tokyo Night"

# Rebuild bat cache (for custom themes)
bat cache --build
echo "Rebuilt bat cache"

echo "Done!"
