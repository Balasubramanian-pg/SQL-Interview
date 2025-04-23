QUERY 2	Display highest and lowest salary
PROBLEM STATEMENT	From the given employee table, display the highest and lowest salary corresponding to each department. Return the result corresponding to each employee record
![image](https://github.com/user-attachments/assets/cf30e82c-cba8-4b23-9881-b3b565ef774c)
# 7 Solutions to Display Highest and Lowest Salary by Department

## Problem Understanding
We need to show each employee record along with the highest and lowest salary in their department. Here are 7 different approaches:

### Solution 1: Using Window Functions
```sql
SELECT 
    id, 
    name, 
    dept, 
    salary,
    MAX(salary) OVER (PARTITION BY dept) AS highest_salary,
    MIN(salary) OVER (PARTITION BY dept) AS lowest_salary
FROM employee;
```

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
