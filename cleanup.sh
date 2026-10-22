#!/bin/sh

cd "$(dirname "$0")"
LABEL=project=chinook 

docker stop $(docker ps -q --filter "label=$LABEL") 2>/dev/null || true 

# stop all containers using the filter label and discarding the standard errors. 
# || true ensures all of the lines still run even when an error happens silently. 

docker rm $(docker ps -aq --filter "label=$LABEL") 2>/dev/null || true 

# remove the stopped containers using the same filter as before

docker volume rm $(docker volume ls -q --filter "label=$LABEL") 2>/dev/null || true 

# remove the volumes using the same filter as before and listing them in the output

docker network rm $(docker network ls -q --filter "label=$LABEL") 2>/dev/null || true

# remove the network using the same filter $LABEL, and printing the network name in the output

docker image rm $(docker images -q --filter "label=$LABEL") 2>/dev/null || true 

# remove all images and use the $LABEL to filter which ones to delete and print them out in the output. 