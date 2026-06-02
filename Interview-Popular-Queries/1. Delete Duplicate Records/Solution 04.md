### Solution 4: Using EXISTS to find duplicates
```sql
DELETE FROM cars c1
WHERE EXISTS (
    SELECT 1
    FROM cars c2
    WHERE c2.model_name = c1.model_name
    AND c2.color = c1.color
    AND c2.brand = c1.brand
    AND c2.model_id < c1.model_id
);
```
