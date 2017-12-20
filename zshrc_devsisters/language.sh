# ruby
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# python
alias python='python3'
# PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
# export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.7/site-packages

# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
source /usr/local/bin/virtualenvwrapper.sh

# java
export JAVA_HOME=`/usr/libexec/java_home`

