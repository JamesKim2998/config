#!/bin/zsh
set -e

CONFIG=$HOME/Develop/config

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# editor
brew install nvim

# search & find
brew install fzf rg fd

# file viewing & data processing
brew install bat jq yq sd

# file navigation & listing
brew install eza lsd zoxide yazi

# system utilities
brew install clipboard procs httpie

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

# task runner & shell
brew install just starship

# casks
brew install --cask libreoffice docker

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# shell
ln -sf $CONFIG/.zshrc ~/.zshrc
ln -sf $CONFIG/starship.toml ~/.config/starship.toml
ln -sf $CONFIG/.ripgreprc ~/.ripgreprc

# git
ln -sf $CONFIG/git/.gitconfig ~/.gitconfig
ln -sf $CONFIG/git/.gitignore_global ~/.gitignore_global

# nvim
rm -rf ~/.config/nvim
ln -s $CONFIG/nvim ~/.config/nvim

# kitty
rm -rf ~/.config/kitty
ln -s $CONFIG/kitty ~/.config/kitty

# yazi
rm -rf ~/.config/yazi
ln -s $CONFIG/yazi ~/.config/yazi

# bat
rm -rf ~/.config/bat
ln -s $CONFIG/bat ~/.config/bat

# lsd
rm -rf ~/.config/lsd
ln -s $CONFIG/lsd ~/.config/lsd

# lazygit
rm -rf "$HOME/Library/Application Support/lazygit"
ln -s $CONFIG/lazygit "$HOME/Library/Application Support/lazygit"

# karabiner
mkdir -p ~/.config/karabiner
ln -sf $CONFIG/karabiner.json ~/.config/karabiner/karabiner.json

# hammerspoon
rm -rf ~/.hammerspoon
ln -s $CONFIG/.hammerspoon ~/.hammerspoon

# gemini
rm -rf ~/.gemini
ln -s $CONFIG/gemini ~/.gemini

# vscode
mkdir -p "$HOME/Library/Application Support/Code/User"
ln -sf $CONFIG/.vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"

# cargo tools
cargo install stylua selene

