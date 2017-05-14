CONFIG_PATH=$HOME/Develop/config
export PATH=$PATH:$CONFIG_PATH/utils

function my_source {
    source $CONFIG_PATH/zshrc_macbook/$1
}

my_source language.sh

my_source framework.sh

