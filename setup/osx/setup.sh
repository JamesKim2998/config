# Install Homebrew first.
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Command line essentials.
brew install zsh
brew install tmux
brew install neovim
brew install autojump
brew install rg
brew install tree
brew install wget

# Language related.
brew install python3

# Utils.
brew install imagemagick
brew install --cask karabiner-elements
brew install --cask rectangle
