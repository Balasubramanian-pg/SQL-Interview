### Solution 6: Using CTE with RANK()
```sql
WITH ranked_cars AS (
    SELECT model_id,
           RANK() OVER (PARTITION BY model_name, color, brand ORDER BY model_id) AS rnk
    FROM cars
)
DELETE FROM cars
WHERE model_id IN (
    SELECT model_id FROM ranked_cars WHERE rnk > 1
);
```
