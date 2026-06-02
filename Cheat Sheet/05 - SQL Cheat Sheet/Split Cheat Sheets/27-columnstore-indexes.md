## 27. Columnstore Indexes
**Purpose:** Improve the performance of analytical queries by storing data in a columnar format rather than row-based, which is particularly effective for large data warehouses.

**Example (SQL Server):**
```sql
CREATE COLUMNSTORE INDEX idx_ColumnStore
ON Sales (SaleID, Amount);
```