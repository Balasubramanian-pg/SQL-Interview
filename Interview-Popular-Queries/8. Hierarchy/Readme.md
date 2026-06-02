# Find the hierarchy
## PROBLEM STATEMENT	
Find the hierarchy of employees under a given manager "Asha".


# SQL Query to Find Employee Hierarchy Under "Asha"

## Solution Using Recursive Common Table Expression (CTE)

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: Start with Asha
    SELECT 
        id,
        name,
        manager_id,
        salary,
        designation,
        1 AS level,
        name AS hierarchy_path
    FROM 
        employees
    WHERE 
        name = 'Asha'
    
    UNION ALL
    
    -- Recursive case: Find all employees who report to someone in the hierarchy
    SELECT 
        e.id,
        e.name,
        e.manager_id,
        e.salary,
        e.designation,
        eh.level + 1,
        eh.hierarchy_path || ' -> ' || e.name
    FROM 
        employees e
    JOIN 
        employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT 
    id,
    name,
    manager_id,
    salary,
    designation,
    level,
    hierarchy_path
FROM 
    employee_hierarchy
ORDER BY 
    level, name;
```
