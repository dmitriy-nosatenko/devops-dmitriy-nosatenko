#!/bin/sh
cd "$(dirname "$0")"
LABEL=project=chinook 

docker volume rm $(docker volume ls -q --filter "label=$LABEL") 2>/dev/null || true 

docker network rm $(docker network ls -q --filter "label=$LABEL") 2>/dev/null || true