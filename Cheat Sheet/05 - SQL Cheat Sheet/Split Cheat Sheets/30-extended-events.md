## 30. Extended Events
**Purpose:** Monitor, diagnose, and troubleshoot performance and other issues in SQL Server by capturing detailed event data.

**Example (SQL Server):**
```sql
CREATE EVENT SESSION QueryMonitor ON SERVER 
ADD EVENT sqlserver.sql_statement_completed
ADD TARGET package0.event_file(SET filename = N'QueryMonitor.xel');
ALTER EVENT SESSION QueryMonitor ON SERVER STATE = START;
```