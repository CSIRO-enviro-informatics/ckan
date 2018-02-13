#!/bin/bash
if [ -z "$CONFIRM_RESTORE" ]
then
   read -p "Do you want to go ahead with the restore this will overrite the database. Y/y to proceed or any other key to cancel" -n 1 -r
   GO=$REPLY
else
   GO="$CONFIRM_RESTORE"
fi  
echo    # (optional) move to a new line
echo $GO
if [[ $GO =~ ^[Yy]$ ]]
then
echo "Restoring the CKAN Database"
pg_restore --verbose --clean --if-exists -U ckan -d ckan -h db < "/backups/ckan/daily/$CKAN_BACKUP_FILE_NAME"
if [ -z "$DATASTORE_BACKUP_FILE_NAME" ]
then
   exit
else
   echo "Restoring the Datastore Database"
   pg_restore --verbose --clean --if-exists -U ckan -d datastore -h db < "/backups/datastore/daily/$DATASTORE_BACKUP_FILE_NAME"
fi
fi 
