COMPOSE_FILE=$1

if [ -z $COMPOSE_FILE ]; then
    echo 'compose-file argument missing'
    return 1
fi

docker-compose -f $COMPOSE_FILE stop
docker-compose down -v
