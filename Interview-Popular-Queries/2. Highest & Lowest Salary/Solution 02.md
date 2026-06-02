### Solution 2: Using JOIN with Aggregated Subquery
```sql
SELECT 
    e.id, 
    e.name, 
    e.dept, 
    e.salary,
    d.max_salary AS highest_salary,
    d.min_salary AS lowest_salary
FROM employee e
JOIN (
    SELECT 
        dept, 
        MAX(salary) AS max_salary, 
        MIN(salary) AS min_salary
    FROM employee
    GROUP BY dept
) d ON e.dept = d.dept;
```
