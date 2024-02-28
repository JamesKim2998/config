CONFIG=$HOME/Develop/config

# git
ln -s $CONFIG/git/.gitconfig ~
ln -s $CONFIG/git/.gitignore_global ~

# nvim - link config
mkdir -p ~/.config/nvim
ln -s $CONFIG/init.vim ~/.config/nvim
# nvim - install plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh - autosuggestion
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# zshrc
ln -s $CONFIG/.zshrc ~
ln -s $CONFIG/.zshrc_alias ~
ln -s $CONFIG/.zshrc_utils ~