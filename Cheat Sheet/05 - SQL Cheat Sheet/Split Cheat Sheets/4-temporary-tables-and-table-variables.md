## 4. Temporary Tables and Table Variables
**Purpose:** Store intermediate results temporarily during complex query processing.

**Example (Temporary Table in MySQL):**
```sql
CREATE TEMPORARY TABLE TempSales (
    sale_id INT,
    sale_amount DECIMAL(10,2)
);

INSERT INTO TempSales (sale_id, sale_amount) VALUES (1, 100.00);
SELECT * FROM TempSales;
```
*Temporary tables exist only for the duration of your session, allowing you to break down complex operations.*