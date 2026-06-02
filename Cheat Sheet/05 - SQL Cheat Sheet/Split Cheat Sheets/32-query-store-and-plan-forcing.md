## 32. Query Store and Plan Forcing  
**Purpose:**  
Capture historical query performance data to analyze and optimize queries. The Query Store also allows you to force a specific query plan if needed, helping mitigate performance regressions.  

**Example (SQL Server):**  
```sql
-- Enable Query Store on your database
ALTER DATABASE YourDatabase SET QUERY_STORE = ON;
```
After enabling, you can review performance data in SQL Server Management Studio and, if necessary, force an optimal plan using query hints (e.g., `OPTION (USE PLAN N'...')`).