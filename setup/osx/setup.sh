# Install Homebrew first.
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Command line essentials.
brew install zsh
brew install tmux
brew install nvim
brew install autojump
brew install rg

# Language related.
brew install python2
brew install python3
brew cask install java

# Utils.
brew install trash
brew cask install karabiner-elements

