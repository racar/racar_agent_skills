# Common PostgreSQL Queries

Reference guide for frequently used PostgreSQL queries and patterns.

## Table of Contents

1. [Data Retrieval (SELECT)](#data-retrieval-select)
2. [Data Modification (INSERT/UPDATE/DELETE)](#data-modification)
3. [Table Information](#table-information)
4. [Database Administration](#database-administration)
5. [Joins and Relationships](#joins-and-relationships)
6. [Aggregation and Grouping](#aggregation-and-grouping)

---

## Data Retrieval (SELECT)

### Basic SELECT
```sql
SELECT * FROM users;
SELECT id, email, created_at FROM users;
SELECT * FROM users LIMIT 10;
```

### WHERE Conditions
```sql
SELECT * FROM users WHERE email = 'user@example.com';
SELECT * FROM users WHERE created_at > '2024-01-01';
SELECT * FROM users WHERE active = true AND role = 'admin';
SELECT * FROM products WHERE price BETWEEN 10 AND 50;
SELECT * FROM users WHERE email LIKE '%@gmail.com';
SELECT * FROM users WHERE id IN (1, 2, 3, 4, 5);
```

### Ordering and Pagination
```sql
SELECT * FROM users ORDER BY created_at DESC;
SELECT * FROM products ORDER BY price ASC, name DESC;
SELECT * FROM users ORDER BY created_at DESC LIMIT 20 OFFSET 40;
```

### Distinct Values
```sql
SELECT DISTINCT status FROM orders;
SELECT DISTINCT country FROM users;
```

---

## Data Modification

### INSERT
```sql
-- Single row
INSERT INTO users (email, name, role)
VALUES ('user@example.com', 'John Doe', 'user');

-- Multiple rows
INSERT INTO logs (level, message, created_at)
VALUES
  ('INFO', 'Application started', NOW()),
  ('DEBUG', 'Config loaded', NOW());

-- Return inserted data
INSERT INTO users (email, name)
VALUES ('new@example.com', 'Jane Doe')
RETURNING id, created_at;
```

### UPDATE
```sql
-- Update single column
UPDATE users SET active = false WHERE id = 123;

-- Update multiple columns
UPDATE products
SET price = 29.99, updated_at = NOW()
WHERE id = 456;

-- Update with condition
UPDATE orders
SET status = 'shipped', shipped_at = NOW()
WHERE status = 'processing' AND created_at < NOW() - INTERVAL '2 days';

-- Return updated data
UPDATE users
SET last_login = NOW()
WHERE email = 'user@example.com'
RETURNING id, last_login;
```

### DELETE
```sql
-- Delete specific rows
DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days';

-- Delete with condition
DELETE FROM sessions WHERE expired = true;

-- Return deleted data
DELETE FROM users WHERE id = 123 RETURNING *;
```

---

## Table Information

### List All Tables
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';
```

### Table Structure
```sql
-- Column details
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users';

-- Table size
SELECT
  pg_size_pretty(pg_total_relation_size('users')) as total_size,
  pg_size_pretty(pg_relation_size('users')) as table_size,
  pg_size_pretty(pg_indexes_size('users')) as indexes_size;
```

### Indexes
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'users';
```

### Foreign Keys
```sql
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = 'orders';
```

---

## Database Administration

### Database Size
```sql
SELECT
  pg_database.datname,
  pg_size_pretty(pg_database_size(pg_database.datname)) AS size
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;
```

### Active Connections
```sql
SELECT
  pid,
  usename,
  datname,
  client_addr,
  state,
  query_start,
  state_change
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;
```

### Kill Connection
```sql
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid = 12345;
```

---

## Joins and Relationships

### INNER JOIN
```sql
SELECT
  orders.id,
  orders.total,
  users.email,
  users.name
FROM orders
INNER JOIN users ON orders.user_id = users.id;
```

### LEFT JOIN
```sql
SELECT
  users.id,
  users.email,
  COUNT(orders.id) as order_count
FROM users
LEFT JOIN orders ON users.id = orders.user_id
GROUP BY users.id, users.email;
```

### Multiple Joins
```sql
SELECT
  orders.id,
  users.email,
  products.name,
  order_items.quantity,
  order_items.price
FROM orders
INNER JOIN users ON orders.user_id = users.id
INNER JOIN order_items ON orders.id = order_items.order_id
INNER JOIN products ON order_items.product_id = products.id;
```

---

## Aggregation and Grouping

### COUNT, SUM, AVG
```sql
-- Count rows
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM users WHERE active = true;

-- Sum
SELECT SUM(total) FROM orders WHERE status = 'completed';

-- Average
SELECT AVG(price) FROM products;

-- Min/Max
SELECT MIN(created_at), MAX(created_at) FROM orders;
```

### GROUP BY
```sql
-- Count by status
SELECT status, COUNT(*) as count
FROM orders
GROUP BY status;

-- Sum by category
SELECT category, SUM(price) as total_value
FROM products
GROUP BY category
ORDER BY total_value DESC;

-- Multiple grouping columns
SELECT
  DATE(created_at) as date,
  status,
  COUNT(*) as count
FROM orders
GROUP BY DATE(created_at), status
ORDER BY date DESC;
```

### HAVING
```sql
-- Filter aggregated results
SELECT
  user_id,
  COUNT(*) as order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 5;
```

### Common Aggregations
```sql
-- Daily order totals
SELECT
  DATE(created_at) as date,
  COUNT(*) as orders,
  SUM(total) as revenue
FROM orders
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- User activity summary
SELECT
  users.email,
  COUNT(DISTINCT orders.id) as total_orders,
  SUM(orders.total) as lifetime_value,
  MAX(orders.created_at) as last_order_date
FROM users
LEFT JOIN orders ON users.id = orders.user_id
GROUP BY users.id, users.email
ORDER BY lifetime_value DESC;
```
