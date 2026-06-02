### Solution 1: Using DISTINCT with CASE
```sql
SELECT DISTINCT
    LEAST(source, destination) AS city1,
    GREATEST(source, destination) AS city2,
    distance
FROM routes;
```
