#!/bin/bash

# It is expected this script will be run from the oflw-science-graph directory as
# . deployment_scripts/docker_refresh_all.sh

CURRENT_DIR_NAME=${PWD##*/}

if [ "$CURRENT_DIR_NAME" != "oflw-science-graph" ]; then
    echo 'must be called from oflw-science-graph like deployment_scripts/scriptname.sh'
    return 1
fi

sh ./deployment_scripts/docker_refresh_all.sh docker-compose_lw-10.yml.yaml
