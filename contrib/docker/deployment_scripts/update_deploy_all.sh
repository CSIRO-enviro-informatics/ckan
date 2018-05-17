#!/bin/bash

# It is expected this script will be run from the oflw-science-graph directory as
# . deployment_scripts/update_deploy_all.sh
PROJECT_NAME=$1
ENV_FILE_LOCATION=$2
DIRECTORY_NAME=$3

if [ -z $DIRECTORY_NAME ]; then
    CURRENT_DIR_NAME=${PWD##*/} 
    echo $CURRENT_DIR_NAME 
    if [ "$CURRENT_DIR_NAME" != "deployment_scripts" ]; then
        echo 'must be called from deployment_scripts like deployment_scripts/scriptname.sh'
        return 1
    fi
fi

if [ -z $PROJECT_NAME ]; then
    echo 'project name argument missing'
    return 1
fi

if [ -z $ENV_FILE_LOCATION ]; then
    echo 'environment file location argument missing'
    return 1
fi

echo 'where am I'
pwd

if [ ! -f $ENV_FILE_LOCATION ]; then
    echo "ERROR - .env file not found!.  Stopping all containers"
    #stop old containers there is a issue with deployment
    chmod +x bring_down_containers.sh 
    cd ..
    sh ./deployment_scripts/bring_down_containers.sh docker-compose.yml $PROJECT_NAME
    return 1
else
    cp $ENV_FILE_LOCATION ../.env
    chmod +x docker_refresh_all.sh
    cd ..
    sh ./deployment_scripts/docker_refresh_all.sh docker-compose.yml $PROJECT_NAME 
fi
