## 26. Change Data Capture (CDC) / Change Tracking
**Purpose:** Track changes made to tables over time so you can capture data modifications for auditing or incremental data processing.

**Example (SQL Server CDC):**
```sql
EXEC sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name   = 'Sales', 
    @role_name     = NULL;
```