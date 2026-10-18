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
-e POSTGRES_USER="$DB_USER" -e POSTGRES_PASSWORD="$DB_PASS" -e POSTGRES_DB="$DB_NAME" \
postgres:17

until docker exec "$DB" pg_isready -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; do sleep 1; done

docker build --target seeder --label "$LABEL" -t chinook-seeder

docker run --rm --name chinook-seeder --network "$NET" --label "$LABEL" \
-v "$(pwd)/Chinook.db:/app.Chinook.db:ro" \
-e SQLITE_FILE=/app/Chinook.db \
-e DATABASE_URL="postgres://$DB_USER:$DB_PASS@$DB:5432/$DB_NAME" \
chinook-seeder 