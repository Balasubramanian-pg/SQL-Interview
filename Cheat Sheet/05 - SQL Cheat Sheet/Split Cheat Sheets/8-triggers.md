## 8. Triggers  
**Purpose:** Automatically execute SQL code in response to certain events on a table, such as INSERT, UPDATE, or DELETE operations.

- **Example:**
  ```sql
  CREATE TRIGGER trg_AfterInsert
  ON orders
  AFTER INSERT
  AS
  BEGIN
      PRINT 'A new order has been inserted.';
  END;
  ```