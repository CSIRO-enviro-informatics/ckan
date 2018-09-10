#!/bin/sh

COMPOSE_PROJECT=${COMPOSE_PROJECT:-CKAN-DEV}
exec docker-compose -p ${COMPOSE_PROJECT} -f ./docker-compose.yml -f ./docker-compose.prod.yml $@

