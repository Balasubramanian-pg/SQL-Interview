## 1. Recursive Common Table Expressions (CTEs)
**Purpose:** Query hierarchical or recursive data such as organizational charts or folder structures.

**Example (SQL Server / PostgreSQL):**
```sql
WITH EmployeeHierarchy AS (
    SELECT employee_id, manager_id, employee_name
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.employee_name
    FROM employees e
    INNER JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM EmployeeHierarchy;
```
*This recursive CTE starts with top-level employees and then recursively joins to retrieve all subordinate employees.*