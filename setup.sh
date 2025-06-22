CONFIG=$HOME/Develop/config

# git
ln -s $CONFIG/git/.gitconfig ~
ln -s $CONFIG/git/.gitignore_global ~

# nvim - link config
mkdir -p ~/.config/nvim
ln -s $CONFIG/init.vim ~/.config/nvim

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zshrc
ln -s $CONFIG/.zshrc ~

