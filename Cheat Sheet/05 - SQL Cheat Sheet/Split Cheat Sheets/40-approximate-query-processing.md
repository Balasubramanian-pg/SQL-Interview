## 40. Approximate Query Processing  
**Purpose:**  
Quickly run aggregations over massive datasets by returning approximate results with a known error margin. This is useful when speed is more critical than exact precision.

**Example (SQL Server / BigQuery):**  
```sql
SELECT APPROX_COUNT_DISTINCT(UserID) AS ApproxUserCount
FROM Logins;
```

*This query calculates an approximate distinct count of users, often much faster than an exact count on very large tables.*