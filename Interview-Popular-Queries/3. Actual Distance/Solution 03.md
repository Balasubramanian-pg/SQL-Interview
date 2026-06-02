## Solution 3: Using Subquery
```sql
SELECT 
    cars,
    days,
    cumulative_distance - COALESCE(
        (SELECT cumulative_distance 
         FROM cars_travel t2 
         WHERE t2.cars = t1.cars AND t2.days < t1.days 
         ORDER BY t2.days DESC 
         LIMIT 1), 0
    ) AS actual_distance
FROM cars_travel t1;
```

