#!/bin/bash

# It is expected this script will be run from the oflw-science-graph directory as
# . deployment_scripts/update_all.sh

CURRENT_DIR_NAME=${PWD##*/}

if [ "$CURRENT_DIR_NAME" != "oflw-science-graph" ]; then
    echo 'must be called from oflw-science-graph like deployment_scripts/scriptname.sh'
    return 1
fi

cd ../oflw-science-graph
git pull

