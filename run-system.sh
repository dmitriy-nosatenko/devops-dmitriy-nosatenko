#!/bin/sh

set -e

cd "$(dirname "$0")"

LABEL=project=chinook
NET=chinook-net
DB=chinook-db
DB_USER=chinook
DB_PASS=chinookpw
DB_NAME=chinook 

docker run -d --name assignment \
       -p 3000:80 \
    assignment-demo:1.0

sleep 10
echo "Container started"
