#!/bin/bash 

set -e

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${CKAN_SQLALCHEMY_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}

CONFIG="${CKAN_CONFIG}/ckan.ini"

abort () {
  echo "$@" >&2
  exit 1
}

set_environment () {
  export CKAN_SQLALCHEMY_URL=${CKAN_SQLALCHEMY_URL}
  export CKAN_SOLR_URL=${CKAN_SOLR_URL}
  export CKAN_REDIS_URL=${CKAN_REDIS_URL}
  export CKAN_STORAGE_PATH=${CKAN_STORAGE_PATH}
  export CKAN_SITE_URL=${CKAN_SITE_URL}
  export CKAN_DEFAULT_ADMIN=${CKAN_SITE_URL}
  export CKAN_LDAP_PASSWORD=${CKAN_LDAP_PASSWORD}
  export CKAN_DATASTORE_WRITE_URL=${CKAN_DATASTORE_WRITE_URL}
  export CKAN_DATASTORE_READ_URL=${CKAN_DATASTORE_READ_URL}
}

write_config () {
  echo "Writing Config" 
  printenv 
  echo "$CKAN_LDAP_PASSWORD" 
  # Note that this only gets called if there is no config, see below!
  ckan-paster make-config --no-interactive ckan "$CONFIG"

  # The variables above will be used by CKAN, but
  # in case want to use the config from ckan.ini use this
  ckan-paster --plugin=ckan config-tool "$CONFIG" -e \
      "sqlalchemy.url = ${CKAN_SQLALCHEMY_URL}" \
      "solr_url = ${CKAN_SOLR_URL}" \
      "ckan.redis.url = ${CKAN_REDIS_URL}" \
      "ckan.storage_path = ${CKAN_STORAGE_PATH}" \
      "ckan.site_url = ${CKAN_SITE_URL}" \
  
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.uri = ldap://pool.ldap.csiro.au:389" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.base_dn = ou=People,dc=nexus,dc=csiro,dc=au" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.search.filter = uid={login}" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.email = mail" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.username = uid" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.auth.dn = sa-clw-ad-access@csiro.au" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.auth.password = ${CKAN_LDAP_PASSWORD}" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.fullname = displayName" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.about = description" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.ckan_fallback = true" 
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.organization.id = csiro"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.organization.role = editor"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.plugins = stats text_view image_view recline_view ldap datastore digitalassetfields csiro_hub_theme"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.anon_create_dataset = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_unowned_dataset = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_dataset_if_not_in_organization = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_create_groups = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_create_organizations = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_delete_groups = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_delete_organizations = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_user_via_api = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_user_via_web = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.roles_that_cascade_to_sub_groups = admin"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.site_title = CSIRO Digital Asset Registry"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.site_logo = /images/csiro-lw-digital-asset-reg.png"


  #ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datastore.write_url = $(link_datastore_postgres_url)"
  #ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datastore.read_url = $(link_datastore_postgres_url)"
}

link_datastore_postgres_url () {
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASSWORD
  local db=datastore
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://${user}:${pass}@${host}:${port}/${db}"
}

link_postgres_url () {
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASSWORD
  local db=$DB_ENV_POSTGRES_DB
  local host=$DB_PORT_5432_TCP_ADDR
  local port=$DB_PORT_5432_TCP_PORT
  echo "postgresql://${user}:${pass}@${host}:${port}/${db}"
}

link_solr_url () {
  local host=$SOLR_PORT_8983_TCP_ADDR
  local port=$SOLR_PORT_8983_TCP_PORT
  echo "http://${host}:${port}/solr/ckan"
}

link_redis_url () {
  local host=$REDIS_PORT_6379_TCP_ADDR
  local port=$REDIS_PORT_6379_TCP_PORT
  echo "redis://${host}:${port}/1"
}

# If we don't already have a config file, bootstrap
if [ ! -e "$CONFIG" ]; then
  write_config
fi

# Set environment variables
if [ -z "$CKAN_SQLALCHEMY_URL" ]; then
  if ! CKAN_SQLALCHEMY_URL=$(link_postgres_url); then
    abort "ERROR: no CKAN_SQLALCHEMY_URL specified and linked container called 'db' was not found"
  fi
fi

if [ -z "$CKAN_SOLR_URL" ]; then
  if ! CKAN_SOLR_URL=$(link_solr_url); then
    abort "ERROR: no CKAN_SOLR_URL specified and linked container called 'solr' was not found"
  fi
fi
    
if [ -z "$CKAN_REDIS_URL" ]; then
  if ! CKAN_REDIS_URL=$(link_redis_url); then
    abort "ERROR: no CKAN_REDIS_URL specified and linked container called 'redis' was not found"
  fi
fi

set_environment

#. ./wait-for-it.sh -t 0 -h http://solr -p 8983 -- echo "solr is up"

./wait-for-it.sh -t 0 -h solr -p 8983 -- echo "solr is up"
./wait-for-it.sh -t 0 -h db -p 5432 -- echo "db is up"

echo "Initializing plugins and database"

# Initializes the Database
ckan-paster --plugin=ckan db init -c "${CKAN_CONFIG}/ckan.ini"
ckan-paster --plugin=ckan user add admin password=admin email=OznomeHelp@csiro.au -c "${CKAN_CONFIG}/ckan.ini" || true
ckan-paster --plugin=ckan sysadmin add admin -c "${CKAN_CONFIG}/ckan.ini" || true

exec "$@"
