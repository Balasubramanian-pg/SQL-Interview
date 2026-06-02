## 21. Query Execution Plans & Optimization Tools  
**Purpose:** Analyze and optimize query performance by reviewing how the database executes SQL statements.

- **EXPLAIN (MySQL/PostgreSQL):**
  ```sql
  EXPLAIN SELECT * FROM orders WHERE customer_id = 123;
  ```
  *This provides insights into index usage, joins, and potential bottlenecks.*

- **Execution Plan Analysis (SQL Server):**
  ```sql
  SET SHOWPLAN_ALL ON;
  SELECT * FROM orders WHERE customer_id = 123;
  SET SHOWPLAN_ALL OFF;
  ```
*Understanding execution plans helps you fine-tune your queries for better performance.*