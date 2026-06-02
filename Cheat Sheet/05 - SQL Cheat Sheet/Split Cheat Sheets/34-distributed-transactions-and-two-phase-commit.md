## 34. Distributed Transactions and Two-Phase Commit  
**Purpose:**  
Ensure atomic operations across multiple databases or servers. Distributed transactions coordinate commits across systems so that either all operations succeed or none do.  

**Example:**  
```sql
BEGIN DISTRIBUTED TRANSACTION;
  -- Execute operations across different databases/servers
  UPDATE DatabaseA.dbo.Orders SET Status = 'Processed' WHERE OrderID = 123;
  UPDATE DatabaseB.dbo.Inventory SET Quantity = Quantity - 1 WHERE ProductID = 456;
COMMIT TRANSACTION;
```
*Note: Distributed transactions require proper configuration of a transaction coordinator (e.g., MSDTC in SQL Server).*