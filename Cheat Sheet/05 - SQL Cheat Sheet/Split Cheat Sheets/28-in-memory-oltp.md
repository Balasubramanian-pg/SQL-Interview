## 28. In-Memory OLTP
**Purpose:** Dramatically boost transaction processing performance by storing and managing data in memory-optimized tables.

**Example (SQL Server):**
```sql
CREATE TABLE InMemorySales (
    SaleID INT NOT NULL PRIMARY KEY NONCLUSTERED,
    Amount DECIMAL(10,2)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
```