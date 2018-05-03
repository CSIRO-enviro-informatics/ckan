#!/bin/bash
set -e

echo "Loading PostGIS extensions into $POSTGRES_DB"
for DB in "$POSTGRES_DB" "datastore_default"; do
  psql --dbname="$DB" -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
     	CREATE EXTENSION IF NOT EXISTS postgis;
EOSQL
done
