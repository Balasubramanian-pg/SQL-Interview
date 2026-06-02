## 16. MERGE / UPSERT  
**Purpose:** Combine insert, update, and delete operations in one atomic statement, which is useful for synchronizing tables.

**Example (SQL Server):**
```sql
MERGE target_table AS target
USING source_table AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET target.value = source.value
WHEN NOT MATCHED BY TARGET THEN
    INSERT (id, value) VALUES (source.id, source.value)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
```
*This statement updates matching records, inserts new ones, and deletes records not present in the source.*