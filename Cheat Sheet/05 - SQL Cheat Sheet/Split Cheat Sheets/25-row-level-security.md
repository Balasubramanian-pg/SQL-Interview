## 25. Row-Level Security
**Purpose:** Enforce fine-grained access control by restricting which rows a user can view or modify.

**Example (SQL Server):**
```sql
-- Create a predicate function:
CREATE FUNCTION dbo.fn_securitypredicate(@CustomerID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS fn_securitypredicate_result
           WHERE @CustomerID = CAST(SESSION_CONTEXT(N'CustomerID') AS INT);

-- Apply the security policy on the Sales table:
CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE dbo.fn_securitypredicate(CustomerID)
ON dbo.Sales
WITH (STATE = ON);
```