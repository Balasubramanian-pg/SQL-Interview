### Solution 6: Using FIRST_VALUE and LAST_VALUE Window Functions
```sql
SELECT 
    id, 
    name, 
    dept, 
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY dept 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY dept 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_salary
FROM employee;
```
