#!/bin/sh
cd "$(dirname "$0")"
LABEL=project=chinook 

docker network rm $(docker network ls -q --filter "label=$LABEL") 2>/dev/null || true