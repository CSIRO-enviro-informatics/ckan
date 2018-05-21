#!/bin/sh

DEBUG=${DEBUG:-}

if [ -z ${DEBUG} ]; then
  # If not set debug...
  COMPOSE_PROJECT=${COMPOSE_PROJECT:-CKAN-DAMC}
  exec docker-compose -p ${COMPOSE_PROJECT} -f ./contrib/docker/docker-compose.yml $@
else
  # Else, it is debug...
  COMPOSE_PROJECT=${COMPOSE_PROJECT:-CKAN-DEV}
  exec docker-compose -p ${COMPOSE_PROJECT} -f ./contrib/docker/docker-compose.yml -f ./contrib/docker/docker-compose.dev.yml $@
fi




