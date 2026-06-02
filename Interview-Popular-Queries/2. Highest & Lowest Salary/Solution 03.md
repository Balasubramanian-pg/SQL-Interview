### Solution 3: Using Correlated Subqueries
```sql
SELECT 
    id, 
    name, 
    dept, 
    salary,
    (SELECT MAX(salary) FROM employee e2 WHERE e2.dept = e1.dept) AS highest_salary,
    (SELECT MIN(salary) FROM employee e2 WHERE e2.dept = e1.dept) AS lowest_salary
FROM employee e1;
```
