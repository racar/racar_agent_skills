#!/bin/bash

# PostgreSQL Query Script
# Auto-detects running PostgreSQL containers and executes queries
#
# Usage:
#   ./query_db.sh <database_name> <sql_query> [container_id]
#
# Examples:
#   ./query_db.sh order_development "SELECT * FROM users LIMIT 10"
#   ./query_db.sh order_development "SELECT * FROM users" c091f5a68780

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arguments
DATABASE_NAME="$1"
SQL_QUERY="$2"
CONTAINER_ID="$3"

# Validate arguments
if [ -z "$DATABASE_NAME" ] || [ -z "$SQL_QUERY" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: $0 <database_name> <sql_query> [container_id]"
    echo ""
    echo "Examples:"
    echo "  $0 order_development \"SELECT * FROM users LIMIT 10\""
    echo "  $0 order_development \"INSERT INTO logs (message) VALUES ('test')\" c091f5a68780"
    exit 1
fi

# Function to find PostgreSQL containers (match any image with 'postgres' in the name)
find_postgres_containers() {
    docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | grep -i postgres | awk '{print $1"\t"$2"\t"$4" "$5" "$6}' 2>/dev/null || true
}

# If container ID not provided, auto-detect
if [ -z "$CONTAINER_ID" ]; then
    echo -e "${BLUE}Searching for PostgreSQL containers...${NC}"

    CONTAINERS=$(find_postgres_containers)

    if [ -z "$CONTAINERS" ]; then
        echo -e "${RED}Error: No running PostgreSQL containers found${NC}"
        echo "Start a PostgreSQL container or specify container ID manually"
        exit 1
    fi

    # Count containers
    CONTAINER_COUNT=$(echo "$CONTAINERS" | wc -l)

    if [ "$CONTAINER_COUNT" -eq 1 ]; then
        CONTAINER_ID=$(echo "$CONTAINERS" | awk '{print $1}')
        CONTAINER_NAME=$(echo "$CONTAINERS" | awk '{print $2}')
        echo -e "${GREEN}Found PostgreSQL container: $CONTAINER_NAME ($CONTAINER_ID)${NC}"
    else
        echo -e "${YELLOW}Multiple PostgreSQL containers found:${NC}"
        echo "$CONTAINERS" | nl
        echo ""
        echo -e "${YELLOW}Please specify container ID as third argument${NC}"
        exit 1
    fi
fi

# Verify container exists and is running
if ! docker ps --filter "id=$CONTAINER_ID" --format "{{.ID}}" | grep -q "$CONTAINER_ID"; then
    echo -e "${RED}Error: Container $CONTAINER_ID not found or not running${NC}"
    exit 1
fi

# Execute query
echo -e "${BLUE}Executing query on database: $DATABASE_NAME${NC}"
echo -e "${BLUE}Query: $SQL_QUERY${NC}"
echo ""

docker exec "$CONTAINER_ID" psql -U postgres -d "$DATABASE_NAME" -c "$SQL_QUERY"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Query executed successfully${NC}"
else
    echo ""
    echo -e "${RED}Query failed with exit code: $EXIT_CODE${NC}"
    exit $EXIT_CODE
fi
