The SQL query to identify employees who earn **more than their direct managers**:

```sql
SELECT 
    e.employee_id,
    e.name AS employee_name
FROM employee e
JOIN employee m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

### 🔍 Explanation:
- We're doing a **self-join** on the `employee` table: alias `e` for employees and `m` for their managers.
- The `ON e.manager_id = m.employee_id` condition links each employee to their manager.
- The `WHERE` clause filters out only those employees whose `salary` is **greater than** their manager's salary.
- We select the `employee_id` and `name` from the employee table.

Let me know if you'd like to extend this to include manager names or department info!
