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

echo 'where am I'
pwd

if [ ! -f ../../../.env ]; then
    echo "ERROR - .env file not found!.  Stopping all containers"
    #stop old containers there is a issue with deployment
    chmod +x bring_down_containers.sh
    cd ..
    sh ./deployment_scripts/bring_down_containers.sh docker-compose.yml
    return 1
else
    cp ../../../.env ../
    chmod +x docker_refresh_all.sh
    cd ..
    sh ./deployment_scripts/docker_refresh_all.sh docker-compose.yml
fi
