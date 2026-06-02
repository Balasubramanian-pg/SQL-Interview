## Solution 2: Using Self-Join
```sql
SELECT 
    t1.cars,
    t1.days,
    t1.cumulative_distance - COALESCE(t2.cumulative_distance, 0) AS actual_distance
FROM cars_travel t1
LEFT JOIN cars_travel t2 ON t1.cars = t2.cars 
    AND t2.days = (
        SELECT MAX(days) 
        FROM cars_travel t3 
        WHERE t3.cars = t1.cars AND t3.days < t1.days
    );
```
