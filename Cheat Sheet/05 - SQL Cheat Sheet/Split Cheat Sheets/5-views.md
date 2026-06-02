## 5. Views  
**Purpose:** Create virtual tables based on the result of a SELECT query. Views simplify complex queries and can provide a layer of security.

- **Example:**
  ```sql
  CREATE VIEW ActiveCustomers AS
  SELECT customer_id, customer_name
  FROM customers
  WHERE active = 1;
  ```