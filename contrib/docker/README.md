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


# Debugging  
This branch has remote debugging features that are turned off by default. This will provide remote debugging capabilities using for pycharm.

Enable these features by setting the DEBUG environment variable when using the `docker-compose.sh` helper, eg:

`env DEBUG=true ./docker-compose.sh build`

_Or_ enable it if manually running docker-compose but passing in the path to the overlay yaml file:

`docker-compose -f ./contrib/docker/docker-compose.yml -f ./contrib/docker/docker-compose.dev.yml build`


The container includes an additional ckan debug plugin.
This plugin will run a pycharm debug client inside CKAN and attempt to connect to a pycharm instance running a debug server at CKAN_REMOTE_DEBUG_IP on port 6666. You should 
set CKAN_REMOTE_DEBUG_IP via a .env file to your full computer name e.g `CKAN_REMOTE_DEBUG_IP=steakpie-cl.nexus.csiro.au`.

Additionally the dev-env docker-compose file adds new anonymous volumes for the ckan source code and ckan config file and ckan entrypoint. These anonymous volumes are persistent as long as they aren't explicitly deleted with something like `docker-compose down -v`. An additional script, `mount.sh` will mount these directories locally to a directory at the root of the ckan deployment called `local_code`. Editing these directories in the host will be reflected in the container and vice versa.

If you are running the containers shutdown the ckan container with `docker-compose stop ckan`. Start up pycharm and open the folder local code. If you are debugging for the first time this will create a hidden folder called .idea under local_code to store your configurations. If it doesn't exist create a new `Python Remote Debug` configuration. Name this something like `damc-ckan-dev`. Ignore the "update your script" instructions this will have happened automatically as part of the docker-compose process. Leave the localhost name set to localhost and the port set to 6666. Important! Change the default path mapping to the following "/home/lei053/damc-ckan/local_code/ckan_src=/usr/lib/ckan/default/src" this is subtle different to the default. Apply the configuration. Select the configuraiton from the debug menu to make it active and start debugging. You should see a message indicating that the debug server is running and waiting for a connection.

Start the ckan container with `docker-compose up -d ckan` or everything (if it isn't already started) with `docker-compose up -d` if starting everything for the first time or starting after having deleted your volumes you will need to run `mount.sh` after then containers have started. 

After a short time you should see a message in the pycharm saying something like:

```
Waiting for process connection...
Connected to pydev debugger (build 173.4301.16)
Starting server in PID 1.
serving on 0.0.0.0:5000 view at http://127.0.0.1:5000
```

You are now ready to start debugging. 

You can set breakpoints in plugins or CKAN source code you can also modify code. If you are modifying code you may need to restart ckan to see the effect. Try `docker-compose stop ckan && docker-compose start ckan`. You may need to also restart you debug session but you should be able to keep your pycharm instance and files being edited open during this process. 

Important! Remember that the volumes are mounted to your machine you don't have a copy. If you delete the containers and volumes you will lose changes. Make sure you git commit and git push changes to repository somewhere regularly as part of development.  

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
