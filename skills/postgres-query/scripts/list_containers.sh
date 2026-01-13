#!/bin/bash

# List PostgreSQL Containers
# Shows all running PostgreSQL containers with database information
#
# Usage:
#   ./list_containers.sh

set -e

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Searching for PostgreSQL containers...${NC}"
echo ""

# Find PostgreSQL containers (match any image with 'postgres' in the name)
CONTAINERS=$(docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | grep -i postgres | awk '{print $1"\t"$2"\t"$4" "$5" "$6}' 2>/dev/null || true)

if [ -z "$CONTAINERS" ]; then
    echo -e "${YELLOW}No running PostgreSQL containers found${NC}"
    echo ""
    echo "All running containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}"
    exit 0
fi

echo -e "${GREEN}PostgreSQL containers found:${NC}"
echo ""
printf "%-15s %-20s %-30s\n" "CONTAINER ID" "NAME" "STATUS"
printf "%-15s %-20s %-30s\n" "------------" "----" "------"
echo "$CONTAINERS" | while IFS=$'\t' read -r id name status; do
    printf "%-15s %-20s %-30s\n" "$id" "$name" "$status"
done

echo ""
echo -e "${BLUE}Listing databases in each container:${NC}"
echo ""

echo "$CONTAINERS" | while IFS=$'\t' read -r id name status; do
    echo -e "${GREEN}Container: $name ($id)${NC}"
    docker exec "$id" psql -U postgres -c "\l" 2>/dev/null || echo "  Failed to list databases"
    echo ""
done
