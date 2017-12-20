CONFIG_PATH=$HOME/Develop/config
export PATH=$PATH:$CONFIG_PATH/utils

function my_source {
    source $CONFIG_PATH/zshrc_devsisters/$1
}

my_source language.sh
my_source proj_mars.sh
my_source etc.sh

