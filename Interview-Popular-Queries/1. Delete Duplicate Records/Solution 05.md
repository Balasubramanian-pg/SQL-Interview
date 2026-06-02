### Solution 5: Using a self-join
```sql
DELETE FROM cars
WHERE model_id IN (
    SELECT c1.model_id
    FROM cars c1
    JOIN cars c2 ON c1.model_name = c2.model_name
                AND c1.color = c2.color
                AND c1.brand = c2.brand
                AND c1.model_id > c2.model_id
);
```
