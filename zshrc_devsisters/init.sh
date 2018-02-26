CONFIG_PATH=$HOME/Develop/config
export PATH=$PATH:$CONFIG_PATH/utils




###### Languages ######

# ruby
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# python
alias python='python3'
# PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
# export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.7/site-packages

# virtualenv
# TODO: replace this with pyenv or something.
# export WORKON_HOME=$HOME/.virtualenvs
# export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
# source /usr/local/bin/virtualenvwrapper.sh

# java
export JAVA_HOME=`/usr/libexec/java_home`

############




###### Utils ######

# Xcode
# export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin
# alias xcbuild="$HOME/Develop/frameworks/xcbuild/build/xcbuild"

# TexturePacker
# export PATH=$PATH:"/Applications/TexturePacker.app/Contents/MacOS"

# GAF converter
# export PATH=$PATH:"/Applications/GAF-Converter.app/Contents/Resources"

############




###### Project MARS ######

MARS=$HOME/Develop/Mars/mars-prototype

alias mars_uni=$MARS/unity
alias mars_ser=$MARS/MarsServer
alias mars_scr=$MARS/scripts

alias code_uni="code $MARS/unity"
alias code_ser="code $MARS/MarsServer"
alias code_scr="code $MARS/scripts"

alias mars_per="$HOME/Library/Application\ Support/devsisters/mars-prototype"

############
