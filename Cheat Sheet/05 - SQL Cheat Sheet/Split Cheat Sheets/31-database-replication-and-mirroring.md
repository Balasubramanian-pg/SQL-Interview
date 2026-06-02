## 31. Database Replication and Mirroring  
**Purpose:**  
Enable high availability and redundancy by replicating data between databases. This helps ensure data remains accessible in case of hardware failures or planned maintenance.  

**Example (Conceptual - SQL Server):**  
Replication is often configured using SQL Server Management Studio and system stored procedures. For example, to set up snapshot replication, you might use:  
```sql
-- This is a conceptual example; actual replication setup involves several steps.
EXEC sp_addpublication 
    @publication = 'MySnapshotPublication', 
    @publication_type = 'snapshot',
    @description = 'Snapshot replication for high availability';
```
*Note: The full setup requires configuring publishers, distributors, and subscribers.*