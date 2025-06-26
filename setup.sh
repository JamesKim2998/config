CONFIG=$HOME/Develop/config

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install nvim fzf rg fd sd 7z eza zoxide lazygit yazi imagemagick ffmpeg

# git
ln -s $CONFIG/git/.gitconfig ~
ln -s $CONFIG/git/.gitignore_global ~

# nvim
mkdir -p ~/.config/nvim
ln -s $CONFIG/init.vim ~/.config/nvim

# zshrc
ln -s $CONFIG/.zshrc ~

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

