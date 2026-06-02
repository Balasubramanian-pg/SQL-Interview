## 14. Hierarchical Queries (Oracle CONNECT BY)  
**Purpose:** Retrieve and display hierarchical data (e.g., organizational structures).

- **Example (Oracle):**
  ```sql
  SELECT employee_id, employee_name, manager_id
  FROM employees
  START WITH manager_id IS NULL
  CONNECT BY PRIOR employee_id = manager_id;
  ```
  *This query builds an organizational hierarchy starting from top-level employees (with no manager).*