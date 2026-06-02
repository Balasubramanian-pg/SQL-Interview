## 7. Stored Procedures & Functions  
**Purpose:** Encapsulate a series of SQL statements for reuse. Procedures perform actions, while functions return a value.

- **Stored Procedure Example:**
  ```sql
  CREATE PROCEDURE GetEmployeeByDept (@dept_id INT)
  AS
  BEGIN
      SELECT employee_name, salary
      FROM employees
      WHERE department_id = @dept_id;
  END;
  ```
- **Function Example (SQL Server):**
  ```sql
  CREATE FUNCTION dbo.GetFullName (@first NVARCHAR(50), @last NVARCHAR(50))
  RETURNS NVARCHAR(101)
  AS
  BEGIN
      RETURN CONCAT(@first, ' ', @last);
  END;
  ```