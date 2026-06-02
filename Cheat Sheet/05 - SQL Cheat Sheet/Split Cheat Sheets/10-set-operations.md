## 10. Set Operations  
**Purpose:** Combine results from multiple SELECT queries.

- **UNION** – Combines results and removes duplicates.
  ```sql
  SELECT column_name FROM tableA
  UNION
  SELECT column_name FROM tableB;
  ```
- **INTERSECT** – Returns only the common records.
  ```sql
  SELECT column_name FROM tableA
  INTERSECT
  SELECT column_name FROM tableB;
  ```
- **EXCEPT (or MINUS)** – Returns records from the first query that aren’t in the second.
  ```sql
  SELECT column_name FROM tableA
  EXCEPT
  SELECT column_name FROM tableB;
  ```