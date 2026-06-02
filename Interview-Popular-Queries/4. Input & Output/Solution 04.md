### Solution 3: Using MIN/MAX Aggregation
```sql
SELECT 
    MIN(source, destination) AS city1,
    MAX(source, destination) AS city2,
    distance
FROM routes
GROUP BY 
    MIN(source, destination),
    MAX(source, destination),
    distance;
```

## Expected Output
```
city1     | city2     | distance
----------|-----------|---------
Bangalore | Hyderabad | 400
Delhi     | Mumbai    | 400
Chennai   | Pune      | 400
```

Note: The solution assumes all bidirectional routes have the same distance. If distances might differ, you would need to handle that case differently (e.g., by averaging or taking the minimum/maximum distance).
