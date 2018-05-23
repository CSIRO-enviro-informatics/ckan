# Requirements

Requires Environment Variables
      
CKAN_HOST_PORT
DATAPUSHER_HOST_PORT
HOST_BACKUP_DIR
HOST_FILE_STORE
CKAN_SITE_BASE_URL
CKAN_PORT
DATASTORE_READONLY_PASSWORD
CKAN_REMOTE_DEBUG_IP
SOLR_PORT_8983_TCP_ADDR
SOLR_PORT_8983_TCP_PORT
MAPBOX_ACCESS_TOKEN

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
CKAN_REMOTE_DEBUG_IP=0.0.0.0 # remote ip of pycharm debug server running on port 6666 for debugging
SOLR_PORT_8983_TCP_ADDR=solr # SOLR hostname or IP address. Use `solr` to point to the built SOLR container.
SOLR_PORT_8983_TCP_PORT=8983 # SOLR Port number. Change this if you are running SOLR on a different port.
MAPBOX_ACCESS_TOKEN=[mapbox api access token] # Place your mapbox token in here in order to activate Mapbox API features that are required by CKAN spatial plugins.


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

To Restore the CKAN and datapusher databases 

WARNING - THIS WILL DELETE YOUR CURRENT DATABASE 


General version
```
deployment_scripts/restore_backup.sh docker-compose.yml [docker project name] [database password] [full path to ckan backup] [full path to datastore backup]
```

WARNING - THIS WILL DELETE YOUR CURRENT DATABASE 

Restoring the latest backup
```
deployment_scripts/restore_backup.sh docker-compose.yml [docker project name] [database password] $(deployment_scripts/find_latest_backup.sh [path to ckan daily backups directory]) $(deployment_scripts/find_latest_backup.sh [path to datastore daily backups directory])
```

WARNING - THIS WILL DELETE YOUR CURRENT DATABASE 

an example 

```
deployment_scripts/restore_backup.sh docker-compose.yml restore_test default_password $(deployment_scripts/find_latest_backup.sh /OSM/MEL/LW_OZNOME/apps/damc-ckan-backups/prod/postgres/ckan/daily) $(deployment_scripts/find_latest_backup.sh /OSM/MEL/LW_OZNOME/apps/damc-ckan-backups/prod/postgres/datastore/daily)
```

# Adding licenses

Add licenses in the static_content/public/licenses.json file. 
