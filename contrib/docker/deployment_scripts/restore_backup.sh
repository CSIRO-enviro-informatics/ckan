#!/bin/bash
COMPOSE_FILE=$1
PROJECT_NAME=$2
DATABASE_PASSWORD=$3
CKAN_BACKUP_FILE_NAME=$4
DATASTORE_BACKUP_FILE_NAME=$5

if [ -z $COMPOSE_FILE ]; then
    echo 'compose-file argument missing'
    exit 1
fi

if [ -z $PROJECT_NAME ]; then
    echo 'project name argument missing'
    exit 1
fi

if [ -z $DATABASE_PASSWORD ]; then
    echo 'database password missing'
    exit 1
fi

if [ -z $CKAN_BACKUP_FILE_NAME ]; then
    echo 'ckan backup file name missing'
    exit 1
fi

if [ -z $DATASTORE_BACKUP_FILE_NAME ]; then
    echo 'datastore backup file name missing'
    exit 1
fi

echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE stop ckan ckan_postgres_backup datastore_postgres_backup 
echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE stop db 
echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE rm -f db
#echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true ckan ckan-paster --plugin=ckan db clean -c /etc/ckan/default/ckan.ini
echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true -e CONFIRM_RESTORE='Y' -e PGPASSWORD=$DATABASE_PASSWORD -e CKAN_BACKUP_FILE_NAME=$CKAN_BACKUP_FILE_NAME -e DATASTORE_BACKUP_FILE_NAME=$DATASTORE_BACKUP_FILE_NAME restore /restore.sh 
echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true ckan ckan-paster --plugin=ckan db upgrade -c /etc/ckan/default/ckan.ini
echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true ckan ckan-paster --plugin=ckan search-index rebuild --config=/etc/ckan/default/ckan.ini
echo docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE up -d ckan
