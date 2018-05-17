#!/bin/bash
COMPOSE_FILE=$1
PROJECT_NAME=$2
DATABASE_PASSWORD=$3
BACKUP_FILE_NAME=$4

if [ -z $COMPOSE_FILE ]; then
    echo 'compose-file argument missing'
    return 1
fi

if [ -z $PROJECT_NAME ]; then
    echo 'project name argument missing'
    return 1
fi

if [ -z $DATABASE_PASSWORD ]; then
    echo 'database password missing'
    return 1
fi

if [ -z $BACKUP_FILE_NAME ]; then
    echo 'backup file name missing'
    return 1
fi

docker-compose stop ckan
docker-compose run ckan ckan-paster --plugin=ckan db clean -c /etc/ckan/default/ckan.ini
docker-compose run -e CONFIRM_RESTORE='Y' -e PGPASSWORD='$DATABASE_PASSWORD' -e CKAN_BACKUP_FILE_NAME='$BACKUP_FILE_NAME' restore /restore.sh 
