#!/bin/bash

# PostgreSQL Backup Restore Script
# Automates the process of loading a PostgreSQL backup into a Docker container

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_usage() {
    echo "Usage: $0 <backup-file> <container-id> <database-name>"
    echo ""
    echo "Arguments:"
    echo "  backup-file    Path to the SQL backup file (e.g., ~/Descargas/qa-order-service.sql)"
    echo "  container-id   Docker container ID or name (e.g., c091f5a68780)"
    echo "  database-name  Name of the database to restore (e.g., order_development)"
    echo ""
    echo "Example:"
    echo "  $0 ~/Descargas/qa-order-service.sql c091f5a68780 order_development"
}

if [ $# -ne 3 ]; then
    print_usage
    exit 1
fi

BACKUP_FILE="$1"
CONTAINER_ID="$2"
DB_NAME="$3"

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

if ! docker ps --format '{{.ID}} {{.Names}}' | grep -q "$CONTAINER_ID"; then
    echo -e "${RED}Error: Container not found or not running: $CONTAINER_ID${NC}"
    exit 1
fi

BACKUP_BASENAME=$(basename "$BACKUP_FILE")
CONTAINER_PATH="/$BACKUP_BASENAME"

echo -e "${YELLOW}=== PostgreSQL Backup Restore Process ===${NC}"
echo -e "Backup file: ${GREEN}$BACKUP_FILE${NC}"
echo -e "Container: ${GREEN}$CONTAINER_ID${NC}"
echo -e "Database: ${GREEN}$DB_NAME${NC}"
echo ""

echo -e "${YELLOW}[1/5]${NC} Copying backup file to container..."
docker cp "$BACKUP_FILE" "$CONTAINER_ID:$CONTAINER_PATH"
echo -e "${GREEN}✓ Backup file copied${NC}"

echo -e "${YELLOW}[2/5]${NC} Dropping existing database..."
docker exec -t "$CONTAINER_ID" psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" || true
echo -e "${GREEN}✓ Database dropped${NC}"

echo -e "${YELLOW}[3/5]${NC} Creating new database..."
docker exec -t "$CONTAINER_ID" psql -U postgres -c "CREATE DATABASE $DB_NAME;"
echo -e "${GREEN}✓ Database created${NC}"

echo -e "${YELLOW}[4/5]${NC} Restoring backup..."
docker exec -t "$CONTAINER_ID" psql -U postgres -d "$DB_NAME" -a -f "$CONTAINER_PATH" > /dev/null 2>&1
echo -e "${GREEN}✓ Backup restored${NC}"

echo -e "${YELLOW}[5/5]${NC} Cleaning up backup file from container..."
docker exec -t "$CONTAINER_ID" rm "$CONTAINER_PATH"
echo -e "${GREEN}✓ Cleanup complete${NC}"

echo ""
echo -e "${GREEN}=== Restore completed successfully ===${NC}"
echo -e "Database ${GREEN}$DB_NAME${NC} has been restored from ${GREEN}$BACKUP_BASENAME${NC}"
