## 12. Materialized Views  
**Purpose:** Store the result of a query physically to speed up retrieval for complex or resource-intensive queries.

- **Example (Oracle):**
  ```sql
  CREATE MATERIALIZED VIEW sales_summary AS
  SELECT salesperson, SUM(sales) AS total_sales
  FROM sales
  GROUP BY salesperson;
  ```
  *Materialized views can be refreshed periodically to provide up-to-date aggregated data.*