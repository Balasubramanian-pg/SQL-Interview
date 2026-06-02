## 4. Window Functions  
**Purpose:** Perform calculations across a set of rows related to the current row, without collapsing the result set.

- **Example (Ranking Salaries):**
  ```sql
  SELECT employee_name, salary,
         RANK() OVER (ORDER BY salary DESC) AS salary_rank
  FROM employees;
  ```