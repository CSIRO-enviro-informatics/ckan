#!/bin/bash
docker-compose down -v --rmi all --remove-orphans 
docker-compose pull 
docker-compose build --no-cache
docker-compose up -d
