# Requirements

Requires Environment Variables
      
      CKAN_SITE_URL
      CKAN_PORT
      DATASTORE_READONLY_PASSWORD
      POSTGRES_PASSWORD
      CKAN_LDAP_PASSWORD

which can be set in an .env file 

file might look like:

CKAN_SITE_URL=http://localhost
CKAN_PORT=5000
DATASTORE_READONLY_PASSWORD=default_password
POSTGRES_PASSWORD=default_password
CKAN_LDAP_PASSWORD=[LDAP PASSWORD]

# Instructions

docker-compose up


# Backup and Restore 

docker-compose stop ckan
docker-compose run ckan ckan-paster --plugin=ckan db clean -c /etc/ckan/default/ckan.ini
docker-compose run -e PGPASSWORD='default_password' --entrypoint='/bin/bash -c' db_restore 'pg_restore --verbose --clean --if-exists -U ckan -d ckan -h db < "/backups/daily/[backup file name]"'
docker-compose run ckan ckan-paster --plugin=ckan search-index rebuild -c /etc/ckan/default/ckan.ini
docker-compose up -d ckan 

