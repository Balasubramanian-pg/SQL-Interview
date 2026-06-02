## 2. Subqueries  
**Purpose:** Use a query inside another query to further refine your data.

- **Example:**
  ```sql
  SELECT employee_name
  FROM employees
  WHERE department_id IN (
      SELECT department_id
      FROM departments
      WHERE location = 'NY'
  );
  ```