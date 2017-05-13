CONFIG_PATH=$HOME/Develop/config
export PATH=$PATH:$CONFIG_PATH/utils

function my_source {
    source $CONFIG_PATH/zshrc_devsisters/$1
}

my_source language.sh

my_source framework/android.sh
#my_source framework/cocos2dx.sh
#my_source framework/google_cloud_platform.sh

my_source projects/mars.sh
#my_source projects/solitaire.sh

my_source sites.sh
my_source etc.sh

