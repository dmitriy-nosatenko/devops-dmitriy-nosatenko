#!/bin/sh

set -e

cd "$(dirname "$0")"

LABEL=project=chinook
NET=chinook-net
DB=chinook-db
DB_USER=chinook
DB_PASS=chinookpw
DB_NAME=chinook

docker network create --label "$LABEL" "$NET"

docker volume create --label "$LABEL" chinook-pgdata


