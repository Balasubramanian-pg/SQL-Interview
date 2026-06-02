## 3. Common Table Expressions (CTE)  
**Purpose:** Create a temporary result set that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement.

- **Example:**
  ```sql
  WITH SalesCTE AS (
      SELECT salesperson, SUM(sales) AS total_sales
      FROM sales
      GROUP BY salesperson
  )
  SELECT *
  FROM SalesCTE
  WHERE total_sales > 10000;
  ```