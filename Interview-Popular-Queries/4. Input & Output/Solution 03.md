### Solution 3: Using Window Functions
```sql
WITH normalized_routes AS (
    SELECT 
        source,
        destination,
        distance,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CASE WHEN source < destination THEN source ELSE destination END,
                CASE WHEN source > destination THEN source ELSE destination END,
                distance
            ORDER BY source
        ) AS rn
    FROM routes
)
SELECT 
    CASE WHEN source < destination THEN source ELSE destination END AS city1,
    CASE WHEN source > destination THEN source ELSE destination END AS city2,
    distance
FROM normalized_routes
WHERE rn = 1;
```
