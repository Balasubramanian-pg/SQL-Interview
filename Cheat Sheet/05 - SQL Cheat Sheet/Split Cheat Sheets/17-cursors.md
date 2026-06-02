## 17. Cursors  
**Purpose:** Process query results row by row when set-based operations aren’t suitable.

**Example (SQL Server):**
```sql
DECLARE @value INT;

DECLARE cursor_example CURSOR FOR
SELECT column_name FROM table_name;

OPEN cursor_example;
FETCH NEXT FROM cursor_example INTO @value;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Process each row individually
    PRINT @value;
    FETCH NEXT FROM cursor_example INTO @value;
END;

CLOSE cursor_example;
DEALLOCATE cursor_example;
```
*Use cursors sparingly, as set-based operations are typically more efficient.*