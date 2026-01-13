---
name: postgres-backup-restore
description: Automate loading PostgreSQL backups from SQL files into local databases running in Docker containers for debugging and testing. Use when working with PostgreSQL database backups, restoring QA/production data to local environments, setting up local debugging environments with real data, or when users mention loading/restoring database backups to Docker containers.
---

# PostgreSQL Backup Restore

## Overview

Automate the process of loading PostgreSQL backup files into local databases running in Docker containers. This skill provides both an automated script and manual workflow for restoring database backups, commonly used for debugging with production/QA data in local development environments.

## Quick Start (Automated)

Use the provided shell script to automate the entire process:

```bash
./scripts/restore_backup.sh <backup-file> <container-id> <database-name>
```

**Example:**
```bash
./scripts/restore_backup.sh ~/Descargas/qa-order-service.sql c091f5a68780 order_development
```

**Arguments:**
- `backup-file`: Path to SQL backup file (e.g., `~/Descargas/qa-order-service-06012026-154531.sql`)
- `container-id`: Docker container ID or name (find with `docker ps`)
- `database-name`: Target database name (e.g., `order_development`)

The script will:
1. Copy backup file to container
2. Drop existing database
3. Create fresh database
4. Restore from backup
5. Clean up temporary files

## Manual Workflow

For situations requiring manual control or customization:

### Step 1: Prepare Backup File

Backup files typically have timestamped names. Optionally rename for convenience:

```bash
# Original: qa-order-service-06012026-154531.sql
# Simplified: qa-order-service.sql
mv ~/Descargas/qa-order-service-06012026-154531.sql ~/Descargas/qa-order-service.sql
```

### Step 2: Copy to Container

Find container ID and copy backup:

```bash
# Find running containers
docker ps

# Copy file to container
docker cp ~/Descargas/qa-order-service.sql c091f5a68780:/qa-order-service.sql
```

### Step 3: Enter Container

```bash
docker exec -it c091f5a68780 bash
```

### Step 4: Drop and Recreate Database

Connect to PostgreSQL:

```bash
psql -U postgres
```

Drop and recreate the database:

```sql
DROP DATABASE order_development;
CREATE DATABASE order_development;
\q
```

### Step 5: Restore Backup

Run the SQL script:

```bash
psql -U postgres -d order_development -a -f /qa-order-service.sql
```

### Step 6: Exit

```bash
exit
```

## Common Use Cases

**QA Data to Local:**
Restore QA environment data to debug issues locally with real data scenarios.

**Production Debugging:**
Load production backup (sanitized) to reproduce and debug production-specific issues.

**Database State Testing:**
Test migrations or schema changes against realistic data volumes and structures.

## Troubleshooting

**Container not found:**
```bash
# List all containers (running and stopped)
docker ps -a

# Start a stopped container
docker start <container-id>
```

**Permission denied:**
```bash
# Ensure you have permissions to access the backup file
ls -la ~/Descargas/qa-order-service.sql

# Make script executable
chmod +x scripts/restore_backup.sh
```

**Database already exists error:**
The automated script handles this with `DROP DATABASE IF EXISTS`. For manual workflow, ensure Step 4 is completed.

**Large backup files:**
Restore process may take several minutes for large backups. The automated script suppresses verbose output for cleaner logs.

## Best Practices

1. **Backup filename convention:** Keep timestamped backups for version tracking
2. **Container identification:** Use `docker ps` to verify container is running before restore
3. **Data sanitization:** Ensure production backups are sanitized (PII removed) before local use
4. **Disk space:** Verify sufficient space in container for backup file
5. **Testing:** Test restored database connectivity after completion

## Resources

### scripts/restore_backup.sh

Automated shell script that handles the complete backup restore workflow. Includes error handling, colored output, and automatic cleanup. Can be executed directly without loading into context.
