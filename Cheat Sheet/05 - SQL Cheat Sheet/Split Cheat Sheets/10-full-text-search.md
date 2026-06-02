## 10. Full-Text Search  
**Purpose:** Perform efficient text searches on large text columns.

- **Example (SQL Server):**
  ```sql
  SELECT *
  FROM articles
  WHERE CONTAINS(content, 'database');
  ```
  *This query searches for the term "database" within the `content` column.*