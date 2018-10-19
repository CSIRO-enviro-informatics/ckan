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
  export CKAN_REMOTE_DEBUG_IP=${CKAN_REMOTE_DEBUG_IP}
  export CKAN_SQLALCHEMY_URL=${CKAN_SQLALCHEMY_URL}
  export CKAN_SOLR_URL=${CKAN_SOLR_URL}
  export CKAN_REDIS_URL=${CKAN_REDIS_URL}
  export CKAN_STORAGE_PATH=${CKAN_STORAGE_PATH}
  export CKAN_SITE_URL=${CKAN_SITE_URL}
  export CKAN_DEFAULT_ADMIN=${CKAN_SITE_URL}
  export CKAN_HOME=${CKAN_HOME}
  export CKAN_LDAP_PASSWORD=${CKAN_LDAP_PASSWORD}
  export CKAN_ADMIN_PASSWORD=${CKAN_ADMIN_PASSWORD}
  export CKAN_DATASTORE_WRITE_URL=${CKAN_DATASTORE_WRITE_URL}
  export CKAN_DATASTORE_READ_URL=${CKAN_DATASTORE_READ_URL}
  export MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}
  export CKAN_DATAPUSHER_URL=${CKAN_DATAPUSHER_URL}
  export BYPASS_DB_INIT=${BYPASS_DB_INIT}
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
      "ckan.site_url = ${CKAN_SITE_URL}"

  ckan-paster --plugin=ckan config-tool "$CONFIG" -s DEFAULT "debug = false"
  if [ "$DEBUG" == "1" ] || [ "$DEBUG" == "true" ]; then
      ckan-paster --plugin=ckan config-tool "$CONFIG" -s DEFAULT "debug = true"
  fi
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.uri = ldap://pool.ldap.csiro.au:389"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.base_dn = ou=People,dc=nexus,dc=csiro,dc=au"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.search.filter = uid={login}"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.email = mail"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.username = uid"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.auth.dn = sa-clw-ad-access@csiro.au"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.auth.password = ${CKAN_LDAP_PASSWORD}"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.fullname = displayName"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.about = description"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.migrate = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.ckan_fallback = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.organization.id = csiro"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.ldap.organization.role = editor"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.cors.origin_allow_all = True"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.spatial.srid = 4326"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.spatial.common_map.type = custom"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.spatial.search_backend = solr"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.spatial.common_map.custom.url =https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png?access_token=${MAPBOX_ACCESS_TOKEN}"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.spatial.common_map.attribution = Map tiles by MapBox"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckanext.geoview.ol_viewer.formats = kml geojson"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.views.default_views = image_view webpage_view recline_grid_view recline_map_view geo_view pdf_view geojson_view"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.activity_streams_email_notifications = False"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "email_to = oznomehelp@example.com"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "error_email_from = oznomehelp@csiro.au"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "smtp.mail_from = oznomehelp@csiro.au"
#  ckan-paster --plugin=ckan config-tool "$CONFIG" "smtp.user = oznomehelp@csiro.au"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "smtp.server = smtp-relay.csiro.au"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datapusher.formats = csv xls xlsx tsv application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datapusher.url = ${CKAN_DATAPUSHER_URL}"

  if [ "$DEVENV" == "1" ] || [ "$DEVENV" == "true" ]; then
      DEVPLUGIN="dev"
  else
      DEVPLUGIN=
  fi

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.plugins = $DEVPLUGIN stats text_view image_view ldap datastore digitalassetfields csiro_hub_theme hierarchy_display hierarchy_form spatial_metadata spatial_query resource_proxy geo_view recline_grid_view recline_map_view recline_graph_view user_ext user_opt_in restricted datarequests dgu_orgs"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datarequests.comments = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datarequests.show_datarequests_badge = false"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.anon_create_dataset = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_unowned_dataset = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_dataset_if_not_in_organization = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_create_groups = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_delete_groups = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_create_organizations = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.user_delete_organizations = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_user_via_api = true"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.create_user_via_web = false"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.auth.roles_that_cascade_to_sub_groups = admin"

  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.site_title = CSIRO Digital Asset Registry"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.site_logo = /images/csiro-lw-digital-asset-reg.png"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.favicon = /images/favicon.ico"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "licenses_group_url = http://staticcontent/licenses.json"


  if [ "$DEVENV" == "1" ] || [ "$DEVENV" == "true" ]; then
      ckan-paster --plugin=ckan config-tool "$CONFIG" "debug.remote = true"
      ckan-paster --plugin=ckan config-tool "$CONFIG" "debug.remote.host.ip= ${CKAN_REMOTE_DEBUG_IP}"
      ckan-paster --plugin=ckan config-tool "$CONFIG" "debug.remote.host.port = 6666"
  fi

  ckan-paster --plugin=ckan config-tool "$CONFIG" "sqlalchemy.url = $(link_postgres_url)"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datastore.write_url = $(link_datastore_postgres_url)"
  ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.datastore.read_url = $(link_datastore_postgres_url)"

  if [ "$PROD" == "1" ] || [ "$PROD" == "true" ]; then
      ckan-paster --plugin=ckan config-tool "$CONFIG" -s "uwsgi" "socket = 0.0.0.0:3031" 
      ckan-paster --plugin=ckan config-tool "$CONFIG" -s "uwsgi" "master = true" 
      ckan-paster --plugin=ckan config-tool "$CONFIG" -s "uwsgi" "processes = 6" 
      ckan-paster --plugin=ckan config-tool "$CONFIG" -s "uwsgi" "virtualenv = ${CKAN_HOME}"
      ckan-paster --plugin=ckan config-tool "$CONFIG" -s "uwsgi" "threads = 2"
      ckan-paster --plugin=ckan config-tool "$CONFIG" "ckan.cache_expires  = 3600"
  fi
}

update_config () {
  # The variables above will be used by CKAN, but
  # in case want to use the config from ckan.ini use this
  if [ "$DEBUG" == "1" ] || [ "$DEBUG" == "true" ]; then
    ckan-paster --plugin=ckan config-tool "$CONFIG" -s DEFAULT "debug = true"
  fi
  ckan-paster --plugin=ckan config-tool "$CONFIG" -e \
      "sqlalchemy.url = ${CKAN_SQLALCHEMY_URL}" \
      "solr_url = ${CKAN_SOLR_URL}" \
      "ckan.redis.url = ${CKAN_REDIS_URL}" \
      "ckan.storage_path = ${CKAN_STORAGE_PATH}" \
      "ckan.site_url = ${CKAN_SITE_URL}" \
      "ckanext.ldap.auth.password = ${CKAN_LDAP_PASSWORD}"
  if [ "$DEBUG" == "1" ] || [ "$DEBUG" == "true" ]; then
    ckan-paster --plugin=ckan config-tool "$CONFIG" -e "debug.remote.host.ip = ${CKAN_REMOTE_DEBUG_IP}"
  fi
}

link_datastore_postgres_url () {
  local user=$DB_ENV_POSTGRES_USER
  local pass=$DB_ENV_POSTGRES_PASSWORD
  local db=datastore_default
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
else
  update_config
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

create_org_and_user_membership () {
  set +e
  export PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD
  cat <<EOF | psql -h $DB_PORT_5432_TCP_ADDR -p $DB_PORT_5432_TCP_PORT -U $DB_ENV_POSTGRES_USER --set ON_ERROR_STOP=1 || true
INSERT INTO ckan.public.revision (id, timestamp, author, message, state)
VALUES ('1e662e20-0c88-492d-8deb-7cac39ae6a14', (now() at time zone 'utc'), 'admin', 'Create CSIRO group and add admin user as member.', 'active')
ON CONFLICT DO NOTHING;

INSERT INTO ckan.public.group (id, name, title, description, created, state, revision_id, type, is_organization)
VALUES ('e70f6776-05f3-48a7-9c24-2fff14e7899a', 'csiro', 'CSIRO', 'CSIRO', (now() at time zone 'utc'), 'active', '1e662e20-0c88-492d-8deb-7cac39ae6a14', 'organization', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO ckan.public.group_revision (id, name, title, description, created, state, revision_id, continuity_id, revision_timestamp, type, is_organization)
VALUES ('e70f6776-05f3-48a7-9c24-2fff14e7899a', 'csiro', 'CSIRO', 'CSIRO', (now() at time zone 'utc'), 'active', '1e662e20-0c88-492d-8deb-7cac39ae6a14', 'e70f6776-05f3-48a7-9c24-2fff14e7899a', (now() at time zone 'utc'), 'organization', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO ckan.public.member (id, table_id, group_id, state, revision_id, table_name, capacity)
VALUES ('e5c180c3-7bbf-4e9a-b060-e14a8d2e58f7', (SELECT id FROM ckan.public.user WHERE name LIKE 'admin' LIMIT 1), 'e70f6776-05f3-48a7-9c24-2fff14e7899a', 'active', '1e662e20-0c88-492d-8deb-7cac39ae6a14', 'user', 'admin')
ON CONFLICT DO NOTHING;

INSERT INTO ckan.public.member_revision (id, table_id, group_id, state, revision_id, continuity_id, revision_timestamp, table_name, capacity)
VALUES ('e5c180c3-7bbf-4e9a-b060-e14a8d2e58f7', (SELECT id FROM ckan.public.user WHERE name LIKE 'admin' LIMIT 1), 'e70f6776-05f3-48a7-9c24-2fff14e7899a', 'active', '1e662e20-0c88-492d-8deb-7cac39ae6a14', 'e5c180c3-7bbf-4e9a-b060-e14a8d2e58f7', (now() at time zone 'utc'), 'user', 'admin')
ON CONFLICT DO NOTHING;
EOF
  unset PGPASSWORD
  set -e
}

#. ./wait-for-it.sh -t 0 -h http://solr -p 8983 -- echo "solr is up"

./wait-for-it.sh -t 0 -h solr -p 8983 -- echo "solr is up"
./wait-for-it.sh -t 0 -h db -p 5432 -- echo "db is up"

if [ -z "$BYPASS_DB_INIT" ]; then
	echo "Initializing plugins and database"
	# Initializes the Database
	ckan-paster --plugin=ckan db init -c "${CKAN_CONFIG}/ckan.ini"
	ckan-paster --plugin=ckanext-spatial spatial initdb -c "${CKAN_CONFIG}/ckan.ini"
	set +e
	export PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD
	ckan-paster --plugin=ckan datastore set-permissions  -c "${CKAN_CONFIG}/ckan.ini"  | psql -h $DB_PORT_5432_TCP_ADDR -p $DB_PORT_5432_TCP_PORT -U $DB_ENV_POSTGRES_USER --set ON_ERROR_STOP=1 || true
	unset PGPASSWORD
	set -e
fi
ckan-paster --plugin=ckan user add admin password=${CKAN_ADMIN_PASSWORD} email=OznomeHelp@csiro.au -c "${CKAN_CONFIG}/ckan.ini" || true
create_org_and_user_membership
ckan-paster --plugin=ckan sysadmin add admin -c "${CKAN_CONFIG}/ckan.ini" || true
exec "$@"
