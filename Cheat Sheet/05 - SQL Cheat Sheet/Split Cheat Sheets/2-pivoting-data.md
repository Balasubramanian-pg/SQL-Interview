## 2. Pivoting Data
**Purpose:** Transform row data into columns for a more intuitive summary or report.

**Example (SQL Server using PIVOT):**
```sql
SELECT *
FROM (
    SELECT year, month, sales
    FROM SalesData
) AS SourceTable
PIVOT (
    SUM(sales)
    FOR month IN ([Jan], [Feb], [Mar])
) AS PivotTable;
```
*This query converts monthly sales rows into columns for January, February, and March.*