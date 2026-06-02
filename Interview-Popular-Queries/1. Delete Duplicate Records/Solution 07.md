### Solution 7: Using DISTINCT ON (PostgreSQL specific)
```sql
DELETE FROM cars
WHERE model_id NOT IN (
    SELECT DISTINCT ON (model_name, color, brand) model_id
    FROM cars
    ORDER BY model_name, color, brand, model_id
);
```

All these solutions will leave one unique record for each combination of model_name, color, and brand, keeping the record with the lowest model_id. Choose the one that best fits your database system and performance requirements.
