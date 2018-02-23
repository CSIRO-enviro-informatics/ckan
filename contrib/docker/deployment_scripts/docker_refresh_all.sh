#!/bin/bash

COMPOSE_FILE=$1

if [ -z $COMPOSE_FILE ]; then
    echo 'compose-file argument missing'
    return 1
fi

# This command should do the job, but it doesn't work all the time? Instead will do manual steps
# docker-compose -f $COMPOSE_FILE up -d --force-recreate
docker-compose -f $COMPOSE_FILE stop
docker rmi $(docker images -q --filter "dangling=true")
docker-compose -f $COMPOSE_FILE build --no-cache
docker-compose -f $COMPOSE_FILE up -d
docker-compose -f $COMPOSE_FILE start
