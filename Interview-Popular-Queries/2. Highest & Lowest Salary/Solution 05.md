### Solution 5: Using LATERAL JOIN (PostgreSQL)
```sql
SELECT 
    e.id, 
    e.name, 
    e.dept, 
    e.salary,
    d.highest_salary,
    d.lowest_salary
FROM employee e
CROSS JOIN LATERAL (
    SELECT 
        MAX(salary) AS highest_salary, 
        MIN(salary) AS lowest_salary
    FROM employee e2
    WHERE e2.dept = e.dept
) d;
```
