# Requirements

Environment Variables
      
- CKAN_HOST_PORT
- DATAPUSHER_HOST_PORT
- HOST_BACKUP_DIR
- HOST_FILE_STORE
- CKAN_SITE_BASE_URL
- CKAN_PORT
- DATASTORE_READONLY_PASSWORD
- CKAN_REMOTE_DEBUG_IP # optional required if debugging
- SOLR_PORT_8983_TCP_ADDR
- SOLR_PORT_8983_TCP_PORT
- MAPBOX_ACCESS_TOKEN
 
These can be set in an local .env file in this directory. Be cautious to specify different values in different .env if you are running multiple instances of ckan on the same machine. 

More information on each variable and some example file contents :

CKAN_HOST_PORT=8081 # CKAN host port may need to be changed if there are multiple instances running the same machine in production mode no service will run on this port and it functions as a dummy port 
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
MAPBOX_ACCESS_TOKEN=[mapbox api access token] # Place your mapbox token in here in order to activate Mapbox API features that are required by CKAN spatial plugins  
DB_HOST_PORT=[host db port] # Optionally define a custom host db port  
STATIC_CONTENT_HOST_PORT=[host static content port] # Optionally define a host custom static content port  

# Instructions

```
docker-compose up -d
```

To clean installation
```
$ docker-compose down -v 
```

To use specific combinations of compose files first
```
$ export COMPOSE_FILE=[compose files seperated with :]
```

for dev env / debug
```
$ export COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
```

for prod 
```
$ export COMPOSE_FILE=docker-compose.yml:docker-compose.prod.yml
```

To run docker-compose using a specific project name to avoid collisions with other instances on the same box use
```
$ export COMPOSE_PROJECT_NAME=[some unique name]
```

> Note that in the above case you may still get port collisions and need to modify your local .env accordingly
> Note that in the above case, the environment variables only valid at current sh session, please add your linux login name to docker group, or else, use `sudo docker-compose ...` command will cause the failure of reading these variables. 

    ```
    sudo usermod -a -G docker $USER
    ```

## Deploy with project name and specified .env file

```bash
cd deployment_scripts
# update_deploy_all.sh project  .env-path 
./update_deploy_all.sh project-name ../.env skipDirCheck
```

# Debugging  

This branch has remote debugging features that are turned off by default. This will provide remote debugging capabilities using for pycharm.

Enable them by setting the COMPOSE_FILE variable like 
```
$ export COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
```

The container includes an additional ckan debug plugin.

This plugin will run a pycharm debug client inside CKAN and attempt to connect to a pycharm instance running a debug server at CKAN_REMOTE_DEBUG_IP on port 6666. You should 
set CKAN_REMOTE_DEBUG_IP via a .env file to your full computer name e.g `CKAN_REMOTE_DEBUG_IP=steakpie-cl.nexus.csiro.au`. Note that if you are using a vm you should make sure that you are port forwarding 6666 to your host port 6666.  

## Mounting Anonymous Volumes For Live Code Editing 

Additionally the dev-env docker-compose file adds new anonymous volumes for the ckan source code and ckan config file and ckan entrypoint. These anonymous volumes are persistent as long as they aren't explicitly deleted with something like `docker-compose down -v`. An additional script, `mount.sh` will mount these directories locally to a directory at the root of the ckan deployment called `local_code`. You'll need sshfs installed on your box try `sudo apt-get install -y sshfs`. Funning this might generate some errors if directories do and don't exist but ultimately you should be prompted for passwords for ssh mounts. As this is just a local sshfs server the password is 'root'. 

If things mounted correctly then from the contrib/docker directory you should be able to see directories at `../../local_code`. These directories are linked to the "live" directories inside the ckan container. Editing these directories in the host will be reflected in the container and vice versa. Note that this approach is used preferentially to regular docker bind mounts because it allows the Dockerfiles to fully configure the contents of these directories rather than requiring you to preconfigure the contents locally on your host prior to running the containers. 

## Getting Debug Running

1. If you are running the containers shutdown the ckan container with `./docker-compose-dev.sh stop ckan`.  
2. Start up pycharm and open the folder local code.  
3. If you are debugging for the first time this will create a hidden folder called .idea under local_code to store your configurations.  
4. If it doesn't exist create a new `Python Remote Debug` configuration. Name this something like `damc-ckan-dev`.  
5. Ignore the "update your script" instructions this will have happened automatically as part of the docker-compose process. Leave the localhost name set to localhost and the port set to 6666. Important! Change the default path mapping to the following or your local equivalent "[my local base directory]/damc-ckan/local_code/ckan_src=/usr/lib/ckan/default/src" this is subtle different to the default. 
6. Apply the configuration.   
7. Select the configuration from the debug menu to make it active and start debugging.   
8. You should see a message indicating that the debug server is running and waiting for a connection.  
9. Start the ckan container with `./docker-compose-dev.sh up -d ckan` or everything (if it isn't already started) with `./docker-compose-dev.sh up -d`, if starting everything for the first time or starting after having deleted your volumes you will need to run `mount.sh` after the containers have started. 

After a short time you should see a message in the pycharm saying something like:

```
Waiting for process connection...
Connected to pydev debugger (build 173.4301.16)
Starting server in PID 1.
serving on 0.0.0.0:5000 view at http://127.0.0.1:5000
```

You are now ready to start debugging. 

Note that you may get some errors as the pycharm can't find some system libraries in "local_code" hit the play button to continue past these errors. 

You can set breakpoints in plugins or CKAN source code you can also modify code. If you are modifying code you may need to restart ckan to see the effect. Try `docker-compose stop ckan && docker-compose start ckan`. You may need to also restart you debug session but you should be able to keep your pycharm instance and files being edited open during this process. 

Important! Remember that the volumes are mounted to your machine you don't have a copy. If you delete the containers and volumes you will lose changes. Make sure you git commit and git push changes to repository somewhere regularly as part of development. 


# Backup and Restore 

## Backup 

Database backup happens automatically daily to the directory specified under HOST_BACKUP_DIR 
CKAN's file store is assumed to be on a backed up file system and can be specified via HOST_FILE_STORE  - NOTE CKAN FILE STORE BACKUP IS NOT WELL TESTED

Database schedules can be modified in the docker-compose.yml and more information on the automated backup approach can be found there.  

## Restore 

To Restore the CKAN and datapusher databases 

WARNING - THIS WILL DELETE YOUR CURRENT DATABASE 

NOTE - CAUTION IS WARRANTED STARTING NEW INSTANCE FOR RESTORE - You should move your desired restore backup to a different location to avoid the unlikely event that it gets overritten by a new backup from a newly instansiated instance.   

General version
```
deployment_scripts/restore_backup.sh [database password] [filename of source ckan backup to use must be in HOST_BACKUP_DIR/postgres/datastore] [filename of source ckan backup to use must be in HOST_BACKUP_DIR/postgres/datastore]
```

WARNING - THIS WILL DELETE YOUR CURRENT DATABASE 

Restoring the latest backup
```
deployment_scripts/restore_backup.sh [database password] $(deployment_scripts/find_latest_backup.sh [path to ckan daily backups directory]) $(deployment_scripts/find_latest_backup.sh [path to datastore daily backups directory])
```

WARNING - THIS WILL DELETE YOUR CURRENT DATABASE 

an example 

```
deployment_scripts/restore_backup.sh default_password $(deployment_scripts/find_latest_backup.sh /OSM/MEL/LW_OZNOME/apps/damc-ckan-backups/prod/postgres/ckan/daily) $(deployment_scripts/find_latest_backup.sh /OSM/MEL/LW_OZNOME/apps/damc-ckan-backups/prod/postgres/datastore/daily)
```

If has error during restore like: `ERROR: Cannot create container for service ckan: Conflict. The container name "/xxxx" is already in use by container "e8d481d2d5dcc73...`, remove the ckan docker first, and try restore again. 

More documentation around the restore process can be found in comments in the restore_backup.sh script


# Adding licenses

Add licenses in the static_content/public/licenses.json file. 
