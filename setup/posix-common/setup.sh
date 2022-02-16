CONFIG=$HOME/Develop/config

# git
ln -s $CONFIG/git/.gitconfig ~
ln -s $CONFIG/git/.gitignore_global ~

# tmux
ln -s $CONFIG/.tmux.conf ~

# scm_breeze
git clone git://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
~/.scm_breeze/install.sh
ln -s $CONFIG/.git.scmbrc ~

# nvim - link config
mkdir -p ~/.config/nvim
ln -s $CONFIG/init.vim ~/.config/nvim
# nvim - install plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# karabiner
mkdir -p ~/.config/karabiner
ln -s $CONFIG/karabiner.json ~/.config/karabiner

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh - autosuggestion
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# zshrc
ln -s $CONFIG/.zshrc ~
ln -s $CONFIG/.zshrc_alias ~
ln -s $CONFIG/.zshrc_utils ~
