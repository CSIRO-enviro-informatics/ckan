#!/bin/bash

# It is expected this script will be run from the oflw-science-graph directory as
# . deployment_scripts/update_deploy_all.sh

if [ "$1" == "" ]; then
    CURRENT_DIR_NAME=${PWD##*/} 
    echo $CURRENT_DIR_NAME 
    if [ "$CURRENT_DIR_NAME" != "deployment_scripts" ]; then
        echo 'must be called from deployment_scripts like deployment_scripts/scriptname.sh'
        return 1
    fi
fi

cp ../../../.env ../

sh ./deployment_scripts/docker_refresh_all.sh ./../docker-compose.yml