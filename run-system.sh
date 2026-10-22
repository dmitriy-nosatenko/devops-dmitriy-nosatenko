#!/bin/sh

set -e

cd "$(dirname "$0")"

LABEL=project=chinook
NET=chinook-net
DB=chinook-db
DB_USER=chinook
DB_PASS=chinookpw
DB_NAME=chinook

#initiating the database metadata as well as the label and network name

docker network create --label "$LABEL" "$NET"

# creating a network named chinook-net

docker volume create --label "$LABEL" chinook-pgdata

# creating a volume called chinook-pgdata

docker run -d --name "$DB" --network "$NET" --label "$LABEL" \
-v chinook-pgdata:/var/lib/postgresql/data \
-e POSTGRES_USER="$DB_USER" -e POSTGRES_PASSWORD="$DB_PASS" -e POSTGRES_DB="$DB_NAME" \
postgres:17

# create a new container called chinook-db
# its created in the chinook-net network
# mounting the volume chinook-pgdata to the database and use the DB credentials for the database startup

until docker exec "$DB" pg_isready -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; do sleep 1; done

# run the pg_isready inside chinook-db container, until Postgres accepts the connection
# discards stdout to >/dev/null & sends 2>&1 to the same place as well; also discarded.

docker build --target seeder --label "$LABEL" -t chinook-seeder .

# build only the seeder from the alpine specified in the Dockerfile with the tag chinook-seeder. 

docker run --rm --name chinook-seeder --network "$NET" --label "$LABEL" \
-v "$(pwd)/Chinook.db:/app/Chinook.db:ro" \
-e SQLITE_FILE=/app/Chinook.db \
-e DATABASE_URL="postgres://$DB_USER:$DB_PASS@$DB:5432/$DB_NAME" \
chinook-seeder 

# binds the hosts Chinook.db into the container /app/Chinook.db using read-only permissions. 
# moves the data from the chinook.db to the postgres database using the credentials provided above

docker run -d --name mcp-gateway --network "$NET" --label "$LABEL" \
-v /var/run/docker.sock:/var/run/docker.sock \
-v "$(pwd)/mcp_config.yaml:/mcp_config.yaml:ro" \
-v "$(pwd)/mcp_secret.env:/run/secrets/database-url:ro" \
docker/mcp-gateway:latest \
--transport=sse \
--secrets=/run/secrets/database-url \
--allow-unauthenticated \
--servers=cockroachdb \
--tools=execute_query \
--config=/mcp_config.yaml 

# creating a container called mcp-gateway in the network specified above, and using the $LABEL
# mounting multiple files from the working directory (pwd) into the container environment variables of the same names
# using the file paths provided in the READMD.md for the docker.sock/ mcp_config.yaml/ mcp_secret.env & the other arguments too.  

until docker logs mcp-gateway 2>&1 | grep -q "Start sse server"; do sleep 1; done

# prints the gateway logs, merges stderr into stdout so all of the logs go into the pipe
# grep searches for the "Start sse server" string, and ends the loop, once the logs contain the string. 

docker build --target agent --label "$LABEL" -t chinook-agent . 

# builds the agent and tags the image with chinook-agent.  

docker run --rm --name chinook-agent --network "$NET" --label "$LABEL" \
-v "$(pwd)/secret.ollama-api-key:/run/secrets/openai-api-key:ro" \
-e MCP_SERVER_URL=http://mcp-gateway:8811/sse \
-e DATABASE_DIALECT=PostgreSQL \
-e QUESTION="What are the top 3 albums by sales?" \
-e OPENAI_API_BASE_URL=https://ollama.com/v1 \
-e OPENAI_MODEL_NAME=gpt-oss:20b \
chinook-agent 

# mounting multiple components from the localhost into the container environment network.
# using the variables as specified in the README.md 
# use -e to specify variables inside the container
# use the chinook-agent image 