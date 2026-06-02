### Solution 7: Using CROSS APPLY (SQL Server)
```sql
SELECT 
    e.id, 
    e.name, 
    e.dept, 
    e.salary,
    d.highest_salary,
    d.lowest_salary
FROM employee e
CROSS APPLY (
    SELECT 
        MAX(salary) AS highest_salary, 
        MIN(salary) AS lowest_salary
    FROM employee e2
    WHERE e2.dept = e.dept
) d;
```

All these solutions will produce the same result, showing each employee along with the highest and lowest salary in their department. The window function approach (Solution 1) is typically the most efficient for this specific requirement.
