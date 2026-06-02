## 20. Security, Roles & Encryption  
**Purpose:** Manage access, permissions, and protect data within the database.

- **Roles & Permissions:**  
  **Example (PostgreSQL):**
  ```sql
  CREATE ROLE read_only;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
  ```
- **Encryption:**  
  Some databases offer built-in encryption features for data-at-rest or during transmission (e.g., Transparent Data Encryption in SQL Server).

*Properly managing security is critical for safeguarding data integrity and privacy.*