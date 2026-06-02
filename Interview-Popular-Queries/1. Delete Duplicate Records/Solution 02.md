### Solution 2: Using ROW_NUMBER() window function
```sql
DELETE FROM cars
WHERE model_id IN (
    SELECT model_id
    FROM (
        SELECT model_id,
               ROW_NUMBER() OVER (PARTITION BY model_name, color, brand ORDER BY model_id) AS rn
        FROM cars
    ) t
    WHERE rn > 1
);
```
