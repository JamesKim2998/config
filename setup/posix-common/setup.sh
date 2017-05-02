# git - install breeze
git clone git://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze
~/.scm_breeze/install.sh

# git - set user info
git config --global core.editor nvim
git config --global user.email "james.kim@devsisters.com"
git config --global user.name "JamesKim"

# nvim
mkdir -p ~/.config/nvim
ln -s ../../init.vim ~/.config/nvim

# nvim - install plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
