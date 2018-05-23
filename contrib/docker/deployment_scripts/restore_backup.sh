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

# Stop the ckan and the backup containers they shouldn't be running during a restore  
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE stop ckan ckan_postgres_backup datastore_postgres_backup 
# Stop the ckan and datastore db 
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE stop db 
# Delete the ckan database because - this is the cleanest (and possibly only working) way to get a blank slate ready for restore, the ckan-paster ckan clean command doesn't seem to be compatible with plugins 
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE rm -f db
# Create and start an new database - this will be empty
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE up -d db
# Sleep to give the database time to come backup
sleep 20s
# Run the restore container this container is a container with postgres client tools and a restore script that uses native postgres restore mechanisms to restore ckan and datastore backup dumps that are passed in
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true -e CONFIRM_RESTORE='Y' -e PGPASSWORD=$DATABASE_PASSWORD -e CKAN_BACKUP_FILE_NAME=$CKAN_BACKUP_FILE_NAME -e DATASTORE_BACKUP_FILE_NAME=$DATASTORE_BACKUP_FILE_NAME restore /restore.sh 
# Unclear when we might need to execute this or the side effects of uncessarily executing it but here for documentation - this might be needed for a major ckan upgrade see the ckan documentation
#docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true ckan ckan-paster --plugin=ckan db upgrade -c /etc/ckan/default/ckan.ini
# Rebuild the search index in solr with the new records 
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE run -e BYPASS_DB_INIT=true ckan ckan-paster --plugin=ckan search-index rebuild --config=/etc/ckan/default/ckan.ini
# Bring backup the ckan and backup containers - data should now be restored  
docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE up -d 
