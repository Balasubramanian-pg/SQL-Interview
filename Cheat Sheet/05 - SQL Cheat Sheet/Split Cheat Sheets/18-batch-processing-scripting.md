## 18. Batch Processing & Scripting  
**Purpose:** Execute multiple SQL statements as a single unit or batch.

**Example (T-SQL):**
```sql
-- This batch creates a temporary table, inserts data, and selects from it.
CREATE TABLE #TempData (id INT, value VARCHAR(50));

INSERT INTO #TempData (id, value)
VALUES (1, 'A'), (2, 'B');

SELECT * FROM #TempData;
GO  -- Marks the end of a batch in SQL Server.
```
*Batches can help organize scripts and control execution flow.*