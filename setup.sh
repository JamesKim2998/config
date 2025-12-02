#!/bin/zsh
set -e

CONFIG=$HOME/Develop/config

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install \
	nvim fzf rg bat fd sd jq yq \
	eza lsd zoxide clipboard procs httpie \
	7-zip ouch imagemagick ffmpeg \
	lazygit delta git-lfs gh copilot \
	lua rust go node oven-sh/bun/bun dotnet \
	gemini-cli awscli \
	yazi starship
brew install --cask \
	libreoffice docker

# zshrc
ln -s $CONFIG/.zshrc ~

# git
ln -s $CONFIG/git/.gitconfig ~
ln -s $CONFIG/git/.gitignore_global ~

# nvim
mkdir -p ~/.config/nvim
ln -s $CONFIG/init.vim ~/.config/nvim

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# bat
rm -rf $HOME/.config/bat
ln -s $CONFIG/bat $HOME/.config/bat

# lazygit
LAZYGIT_DIR="$HOME/Library/Application Support/lazygit"
rm -rf "$LAZYGIT_DIR"
ln -s $CONFIG/lazygit "$LAZYGIT_DIR"

# cargo
cargo install stylua selene

