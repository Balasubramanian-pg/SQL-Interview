## 9. Advanced Window Functions  
**Purpose:** Retrieve values from rows before or after the current row without collapsing the result set.

- **LEAD() and LAG()**  
  **Example:**
  ```sql
  SELECT
      employee_name,
      salary,
      LAG(salary, 1) OVER (ORDER BY salary) AS previous_salary,
      LEAD(salary, 1) OVER (ORDER BY salary) AS next_salary
  FROM employees;
  ```
  *This returns the previous and next salary relative to each employee's salary.*

- **FIRST_VALUE() and LAST_VALUE()**  
  **Example:**
  ```sql
  SELECT
      employee_name,
      salary,
      FIRST_VALUE(salary) OVER (ORDER BY salary DESC) AS highest_salary,
      LAST_VALUE(salary) OVER (ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_salary
  FROM employees;
  ```
  *These functions fetch the first and last values in a window, respectively.*