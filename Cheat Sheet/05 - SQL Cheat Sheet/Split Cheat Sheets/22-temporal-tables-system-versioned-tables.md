## 22. Temporal Tables (System-Versioned Tables)
**Purpose:** Automatically track and store the full history of data changes over time, enabling you to query data as it was at any point in time.

**Example (SQL Server):**
```sql
CREATE TABLE EmployeeHistory (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Salary DECIMAL(10,2),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistoryHistory));
```