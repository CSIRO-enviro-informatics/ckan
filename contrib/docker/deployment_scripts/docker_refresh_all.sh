#!/bin/bash

COMPOSE_FILE=$1

if [ -z $COMPOSE_FILE ]; then
    echo 'compose-file argument missing'
    return 1
fi

docker-compose -f $COMPOSE_FILE stop
docker-compose rm -v -f
docker-compose down -v --remove-orphans
docker-compose -f $COMPOSE_FILE build --no-cache --force-rm
docker-compose -f $COMPOSE_FILE up -d
