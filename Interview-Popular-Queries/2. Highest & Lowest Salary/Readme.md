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
