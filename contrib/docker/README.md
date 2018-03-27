# Requirements

Requires Environment Variables
      
      CKAN_SITE_URL
      CKAN_PORT
      DATASTORE_READONLY_PASSWORD
      POSTGRES_PASSWORD
      CKAN_LDAP_PASSWORD
      HOST_BACKUP_DIR
      HOST_FILE_STORE
      DATAPUSHER_HOST_PORT
      CKAN_HOST_PORT

which should be set in an local .env file especially if you are running multiple instances of ckan on the same machine 

More information on each variable and some example values:

CKAN_HOST_PORT=8081 # CKAN host port may need to be changed if there are multiple instances running the same machine
DATAPUSHER_HOST_PORT=8801 # CKAN datapusher host power may need to be changed if there are multiple instances running on the same machine
HOST_BACKUP_DIR=[some backed up file system location] # Make sure this location is unique and you don't overwrite another instances data
HOST_FILE_STORE=[some backed up file system location] # Make sure this location is unique and you don't overwrite another instances data
CKAN_SITE_BASE_URL=http://lw-13-mel.it.csiro.au 
CKAN_PORT=5000 # internal port can be left at 5000
DATASTORE_READONLY_PASSWORD=default_password # these passwords will work out of the box but should be changed for prod deployments
POSTGRES_PASSWORD=default_password
CKAN_LDAP_PASSWORD=[the ldap password]

# Instructions

```
docker-compose up -d
```

To clean installation
```
$ docker-compose down -v 
```

# Backup and Restore 

## Backup 

Database backup happens automatically daily to the directory specified under HOST_BACKUP_DIR 
CKAN's file store is assumed to be on a backed up file system and can be specified via HOST_FILE_STORE 

## Restore 

To Restore the CKAN and datapusher datbases 
```
docker-compose stop ckan
docker-compose run ckan ckan-paster --plugin=ckan db clean -c /etc/ckan/default/ckan.ini
docker-compose run -e PGPASSWORD='default_password' -e BACKUP_FILE_NAME='[backup file name]' restore /restore.sh 
# or to restore non interactively do 
docker-compose run -e CONFIRM_RESTORE='Y' -e PGPASSWORD='default_password' -e CKAN_BACKUP_FILE_NAME='[backup file name]' restore /restore.sh 
# to additionally restore the datastore database
docker-compose run -e PGPASSWORD='default_password' -e DATASTORE_BACKUP_FILE_NAME='[backup file name]' CKAN_BACKUP_FILE_NAME='[backup file name]' restore /restore.sh 
docker-compose run ckan ckan-paster --plugin=ckan search-index rebuild -c /etc/ckan/default/ckan.ini
docker-compose up -d ckan 
```

# Adding licenses

Add licenses in the static_content/public/licenses.json file. 
