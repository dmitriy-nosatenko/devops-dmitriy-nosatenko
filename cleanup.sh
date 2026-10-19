#!/bin/sh

docker stop $(docker ps -q --filter "label=$LABEL") 2>/dev/null || true 

cd "$(dirname "$0")"
LABEL=project=chinook 

docker rm -f $(docker ps -aq --filter "label=$LABEL") 2>/dev/null || true 

docker volume rm $(docker volume ls -q --filter "label=$LABEL") 2>/dev/null || true 

docker network rm $(docker network ls -q --filter "label=$LABEL") 2>/dev/null || true

docker image rm $(docker images -q --filter "label=$LABEL") 2>/dev/null || true 