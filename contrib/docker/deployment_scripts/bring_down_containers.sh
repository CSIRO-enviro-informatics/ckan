COMPOSE_FILE=$1
PROJECT_NAME=$2

if [ -z $COMPOSE_FILE ]; then
    echo 'compose-file argument missing'
    return 1
fi

if [ -z $PROJECT_NAME ]; then
    echo 'project name argument missing'
    return 1
fi

docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE stop
docker-compose -p $PROJECT_NAME down -v
