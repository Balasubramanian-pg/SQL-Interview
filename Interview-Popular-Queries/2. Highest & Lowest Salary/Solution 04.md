### Solution 4: Using Common Table Expression (CTE)
```sql
WITH dept_salaries AS (
    SELECT 
        dept, 
        MAX(salary) AS highest_salary, 
        MIN(salary) AS lowest_salary
    FROM employee
    GROUP BY dept
)
SELECT 
    e.id, 
    e.name, 
    e.dept, 
    e.salary,
    d.highest_salary,
    d.lowest_salary
FROM employee e
JOIN dept_salaries d ON e.dept = d.dept;
```
