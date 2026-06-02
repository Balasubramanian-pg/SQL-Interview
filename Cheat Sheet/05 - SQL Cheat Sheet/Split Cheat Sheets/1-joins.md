## 1. Joins  
**Purpose:** Combine rows from two or more tables based on a related column.

- **INNER JOIN** – Returns rows with matching values in both tables.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  INNER JOIN tableB b ON a.common_field = b.common_field;
  ```

- **LEFT JOIN** – Returns all rows from the left table, and the matched rows from the right table.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  LEFT JOIN tableB b ON a.common_field = b.common_field;
  ```

- **RIGHT JOIN** – Returns all rows from the right table, and the matched rows from the left table.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  RIGHT JOIN tableB b ON a.common_field = b.common_field;
  ```

- **FULL OUTER JOIN** – Returns rows when there is a match in one of the tables.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  FULL OUTER JOIN tableB b ON a.common_field = b.common_field;
  ```