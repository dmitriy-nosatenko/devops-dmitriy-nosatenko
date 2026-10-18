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

docker run -d --name "$DB" --network "$NET" --label "$LABEL" \
-v chinook-pgdata:/var/lib/postgresql/data \
-e POSTGRES_USER="$DB_USER" -e POSTGRES_PASSWORD="DB_PASS" -e POSTGRES_DB="$DB_NAME" \
postgres:17