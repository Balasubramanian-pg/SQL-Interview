# 5. Longest vs. Shortest Delivery Time

**Objective:** Find the difference between the longest and shortest delivery times.

```sql
WITH time_taken AS (
    SELECT 
        r.runner_id, 
        c.order_id, 
        c.order_time, 
        r.pickup_time, 
        DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS delivery_time
    FROM #customer_orders AS c
    JOIN #runner_orders AS r
        ON c.order_id = r.order_id
    WHERE r.distance != 0
)
SELECT 
    (MAX(delivery_time) - MIN(delivery_time)) AS diff_longest_shortest_delivery_time
FROM time_taken
WHERE delivery_time > 1;
```

**Explanation:**
- The `MAX` and `MIN` functions find the longest and shortest times.
- The difference provides the desired result.

**Improvement:** Additional analysis can identify factors influencing these times.
