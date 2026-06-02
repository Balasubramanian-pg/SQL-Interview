## 29. Data Compression
**Purpose:** Reduce the storage footprint of your data and potentially improve I/O performance through row-level or page-level compression.

**Example (SQL Server):**
```sql
ALTER TABLE Sales 
REBUILD PARTITION = ALL 
WITH (DATA_COMPRESSION = PAGE);
```