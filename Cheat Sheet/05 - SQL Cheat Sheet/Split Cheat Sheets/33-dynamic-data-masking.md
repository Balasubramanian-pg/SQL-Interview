## 33. Dynamic Data Masking  
**Purpose:**  
Protect sensitive information by masking it in query results without altering the underlying data. This is particularly useful for limiting exposure in non-privileged environments.  

**Example (SQL Server):**  
```sql
ALTER TABLE Customers
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
```
*This masks the email addresses so that only a partial view is returned to users without proper privileges.*