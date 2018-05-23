#!/bin/bash
BACKUP_DIRECTORY_LOCATION=$1

if [ -z $BACKUP_DIRECTORY_LOCATION ]; then
    echo 'backup directory location missing'
    exit 1
fi

unset -v latest
latest=$(ls -t $BACKUP_DIRECTORY_LOCATION | head -1)
echo $latest
