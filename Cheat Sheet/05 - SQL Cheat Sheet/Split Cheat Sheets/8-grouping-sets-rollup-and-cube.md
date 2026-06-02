## 8. Grouping Sets, ROLLUP, and CUBE
**Purpose:** Perform multi-level aggregations to produce summary reports with subtotals and grand totals.

**Example (ROLLUP in MySQL):**
```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department WITH ROLLUP;
```
*This query returns a row for each department along with an extra row that shows the overall total count.*