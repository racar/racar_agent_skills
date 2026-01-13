---
name: postgres-query
description: Execute SQL queries and data modifications on PostgreSQL databases running in Docker containers. Auto-detects running PostgreSQL containers and executes SELECT, INSERT, UPDATE, and DELETE operations. Use when working with PostgreSQL databases in containers for querying data, modifying records, analyzing database contents, or performing ad-hoc database operations. Triggers on database queries, SQL operations, data inspection, or PostgreSQL interactions.
---

# PostgreSQL Query

Execute SQL queries and data modifications on PostgreSQL databases running in Docker containers with automatic container detection.

## Quick Start

Execute a query using the automated script:

```bash
scripts/query_db.sh <database_name> "<sql_query>" [container_id]
```

**Examples:**
```bash
# Auto-detect container and query users table
scripts/query_db.sh order_development "SELECT * FROM users LIMIT 10"

# Insert data
scripts/query_db.sh order_development "INSERT INTO logs (level, message) VALUES ('INFO', 'Test log')"

# Update records
scripts/query_db.sh order_development "UPDATE users SET active = true WHERE id = 123"

# Specify container explicitly
scripts/query_db.sh order_development "SELECT * FROM orders WHERE status = 'pending'" c091f5a68780
```

## Scripts

### query_db.sh

Main query execution script with auto-detection of PostgreSQL containers.

**Features:**
- Auto-detects single running PostgreSQL container
- Lists multiple containers when more than one is found
- Colored output for better readability
- Error handling and validation
- Supports all SQL operations (SELECT, INSERT, UPDATE, DELETE)

**Arguments:**
1. `database_name` - Target database (e.g., `order_development`, `postgres`)
2. `sql_query` - SQL query to execute (must be quoted)
3. `container_id` - Optional container ID (auto-detected if omitted)

**Connection Details:**
- User: `postgres` (default PostgreSQL superuser)
- Connects via `docker exec` to running containers

### list_containers.sh

List all running PostgreSQL containers with database information.

```bash
scripts/list_containers.sh
```

Shows:
- Container ID and name
- Container status
- Available databases in each container

Use this when:
- Multiple PostgreSQL containers are running
- Unsure which database names exist
- Need to identify the correct container

## Common Workflows

### Inspect Table Data

```bash
# View table structure
scripts/query_db.sh mydb "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users'"

# View recent records
scripts/query_db.sh mydb "SELECT * FROM orders ORDER BY created_at DESC LIMIT 20"

# Count records
scripts/query_db.sh mydb "SELECT COUNT(*) FROM users WHERE active = true"
```

### Modify Data

```bash
# Insert test data
scripts/query_db.sh mydb "INSERT INTO users (email, name) VALUES ('test@example.com', 'Test User') RETURNING id"

# Update records
scripts/query_db.sh mydb "UPDATE products SET price = 29.99 WHERE id = 456"

# Delete old records
scripts/query_db.sh mydb "DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days'"
```

### Database Analysis

```bash
# List all tables
scripts/query_db.sh mydb "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"

# Check table sizes
scripts/query_db.sh mydb "SELECT pg_size_pretty(pg_total_relation_size('users')) as size"

# Active connections
scripts/query_db.sh mydb "SELECT COUNT(*) FROM pg_stat_activity WHERE state != 'idle'"
```

## Advanced Usage

### Complex Queries

For multi-line queries or queries with special characters, use proper quoting:

```bash
scripts/query_db.sh mydb "
  SELECT
    users.email,
    COUNT(orders.id) as order_count,
    SUM(orders.total) as revenue
  FROM users
  LEFT JOIN orders ON users.id = orders.user_id
  GROUP BY users.id, users.email
  ORDER BY revenue DESC
  LIMIT 10
"
```

### Working with Specific Containers

When multiple containers are running, specify the container:

```bash
# List containers first
scripts/list_containers.sh

# Query specific container
scripts/query_db.sh order_development "SELECT * FROM users" c091f5a68780
```

### Transaction-like Operations

For related operations, chain multiple queries:

```bash
# Create and populate table
scripts/query_db.sh mydb "CREATE TABLE temp_data (id SERIAL, value TEXT)"
scripts/query_db.sh mydb "INSERT INTO temp_data (value) VALUES ('test1'), ('test2')"
scripts/query_db.sh mydb "SELECT * FROM temp_data"
```

## Query Examples

See `references/common_queries.md` for comprehensive examples of:
- Data retrieval patterns
- Data modification operations
- Table and schema inspection
- Joins and relationships
- Aggregation and grouping
- Database administration queries

Load this reference when working on complex queries or need query pattern examples.

## Troubleshooting

### No containers found

```bash
# Verify PostgreSQL containers are running
docker ps | grep postgres

# Start a container if needed
docker start <container_name>
```

### Multiple containers found

The script will list all found containers. Either:
- Specify container ID as third argument
- Stop unused containers: `docker stop <container_id>`

### Database does not exist

```bash
# List available databases
scripts/list_containers.sh

# Create database if needed
scripts/query_db.sh postgres "CREATE DATABASE mydb"
```

### Permission denied

Ensure Docker is running and accessible:
```bash
docker ps  # Should list containers without sudo
```

### Query syntax errors

- Ensure query is properly quoted
- Test query syntax first with simple SELECT
- Check PostgreSQL version compatibility

## Connection Information

This skill uses the same connection pattern as the `postgres-backup-restore` skill:

- **User:** `postgres` (default superuser)
- **Method:** `docker exec -it <container_id> psql`
- **Container detection:** Auto-detect from `docker ps` filtering PostgreSQL images

## Best Practices

1. **Quote queries:** Always quote SQL queries to handle spaces and special characters
2. **Limit results:** Use `LIMIT` for large tables to avoid overwhelming output
3. **Test first:** Test UPDATE/DELETE queries with SELECT first
4. **Use RETURNING:** For INSERT/UPDATE/DELETE, use `RETURNING *` to see affected rows
5. **Transaction safety:** The skill executes single queries; use multiple calls for related operations
6. **Database naming:** Use consistent database names across development team

## Integration with Other Skills

Works well with:
- `postgres-backup-restore` - Use this skill to query restored backup data
- Database migrations - Verify migration results with queries
- Data debugging - Inspect and modify data during development
