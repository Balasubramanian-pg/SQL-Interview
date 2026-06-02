## 13. Error Handling with TRY/CATCH  
**Purpose:** Capture and handle errors in SQL code, especially within stored procedures.

- **Example (SQL Server):**
  ```sql
  BEGIN TRY
      -- Statements that might cause an error
      UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
  END TRY
  BEGIN CATCH
      PRINT 'An error occurred: ' + ERROR_MESSAGE();
  END CATCH;
  ```
  *This structure catches errors and provides a mechanism to handle them gracefully.*