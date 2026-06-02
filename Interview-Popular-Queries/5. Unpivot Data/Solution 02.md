
## Alternative Solutions

### Solution 2: Using Recursive CTE
```sql
WITH RECURSIVE ungrouped AS (
    SELECT 
        id, 
        item_name, 
        1 AS iteration, 
        total_count
    FROM items
    
    UNION ALL
    
    SELECT 
        id, 
        item_name, 
        iteration + 1, 
        total_count
    FROM ungrouped
    WHERE iteration < total_count
)
SELECT 
    id, 
    item_name,
    1 AS count_per_item
FROM ungrouped
ORDER BY id, iteration;
```

