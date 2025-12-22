#!/bin/zsh
set -e

CONFIG=$HOME/Develop/config
XDG_CONFIG=$HOME/.config
APP_SUPPORT="$HOME/Library/Application Support"

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# editor
brew install nvim

# search & find
brew install fzf rg fd

# file viewing & data processing
brew install bat jq yq sd glow miller

# file navigation & listing
brew install eza zoxide yazi tree

# yazi previews (pandoc for docx/odt/epub)
brew install ffmpegthumbnailer poppler exiftool mediainfo pandoc

# system utilities
brew install clipboard procs httpie wget

# compression & archives
brew install 7-zip ouch

# media processing
brew install imagemagick ffmpeg

# git tools
brew install lazygit delta git-lfs gh copilot

# languages & runtimes
brew install lua rust go node oven-sh/bun/bun dotnet

# cloud & cli tools
brew install gemini-cli awscli

# shell tools
brew install just starship shellcheck gnu-sed

# casks
brew install --cask libreoffice docker font-hack-nerd-font

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# shell
ln -sf "$CONFIG/.zshrc" ~/.zshrc
ln -sf "$CONFIG/starship.toml" "$XDG_CONFIG/starship.toml"
ln -sf "$CONFIG/.ripgreprc" ~/.ripgreprc

# git
ln -sf "$CONFIG/git/.gitconfig" ~/.gitconfig
ln -sf "$CONFIG/git/.gitignore_global" ~/.gitignore_global

# nvim
rm -rf "$XDG_CONFIG/nvim"
ln -s "$CONFIG/nvim" "$XDG_CONFIG/nvim"

# kitty
rm -rf "$XDG_CONFIG/kitty"
ln -s "$CONFIG/kitty" "$XDG_CONFIG/kitty"

# yazi
rm -rf "$XDG_CONFIG/yazi"
ln -s "$CONFIG/yazi" "$XDG_CONFIG/yazi"

# bat
rm -rf "$XDG_CONFIG/bat"
ln -s "$CONFIG/bat" "$XDG_CONFIG/bat"

# lazygit
rm -rf "$APP_SUPPORT/lazygit"
ln -s "$CONFIG/lazygit" "$APP_SUPPORT/lazygit"

# karabiner
mkdir -p "$XDG_CONFIG/karabiner"
ln -sf "$CONFIG/karabiner.json" "$XDG_CONFIG/karabiner/karabiner.json"

# hammerspoon
rm -rf ~/.hammerspoon
ln -s "$CONFIG/.hammerspoon" ~/.hammerspoon

# gemini
rm -rf ~/.gemini
ln -s "$CONFIG/gemini" ~/.gemini

# vscode
mkdir -p "$APP_SUPPORT/Code/User"
ln -sf "$CONFIG/.vscode/settings.json" "$APP_SUPPORT/Code/User/settings.json"

# cargo tools
cargo install stylua selene

