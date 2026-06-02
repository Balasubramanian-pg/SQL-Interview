## 5. JSON Functions
**Purpose:** Parse, query, and generate JSON data directly within your SQL queries.

**Example (MySQL):**
```sql
SELECT JSON_EXTRACT(json_column, '$.name') AS name
FROM json_table;
```
*This extracts the `name` field from a JSON column, making it easier to work with JSON data stored in your database.*