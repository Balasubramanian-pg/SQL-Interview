
## Solution 5: Using FIRST_VALUE (Alternative Window Function)
```sql
SELECT 
    cars,
    days,
    cumulative_distance - FIRST_VALUE(cumulative_distance) OVER (
        PARTITION BY cars, grp
        ORDER BY days
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS actual_distance
FROM (
    SELECT 
        cars,
        days,
        cumulative_distance,
        SUM(CASE WHEN days = 'Day1' THEN 1 ELSE 0 END) OVER (
            PARTITION BY cars 
            ORDER BY days
        ) AS grp
    FROM cars_travel
) t;
```

### Expected Result:
```
cars | days | actual_distance
-----|------|----------------
Car1 | Day1 | 50
Car1 | Day2 | 50  (100-50)
Car1 | Day3 | 100 (200-100)
Car2 | Day1 | 0
Car3 | Day1 | 0
Car3 | Day2 | 50  (50-0)
Car3 | Day3 | 0   (50-50)
Car3 | Day4 | 50  (100-50)
```

