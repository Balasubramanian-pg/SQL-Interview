## 3. Dynamic SQL
**Purpose:** Build and execute SQL queries dynamically at runtime, which is useful when table names or conditions vary.

**Example (SQL Server):**
```sql
DECLARE @sql NVARCHAR(4000);
DECLARE @TableName NVARCHAR(100) = 'Orders';
SET @sql = 'SELECT * FROM ' + QUOTENAME(@TableName);
EXEC sp_executesql @sql;
```
*This example constructs a SQL statement using a variable for the table name and executes it safely.*