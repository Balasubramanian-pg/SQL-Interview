## 9. Transactions  
**Purpose:** Ensure a sequence of SQL statements are executed as a single unit, maintaining data integrity.

- **Example:**
  ```sql
  BEGIN TRANSACTION;
      UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
      UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
  COMMIT;
  ```