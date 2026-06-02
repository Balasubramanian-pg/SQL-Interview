

## 4. Average Distance Traveled by Customers

**Objective:** Calculate the average distance traveled for each customer.

```sql
SELECT 
    c.customer_id, 
    AVG(r.distance) AS avg_distance
FROM #customer_orders AS c
JOIN #runner_orders AS r
    ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id;
```

**Explanation:**
- The query calculates the average distance from order data.
- Filtering ensures only valid distances are included.

**Improvement:** Introducing a geospatial function could improve accuracy if raw coordinates are available.

---

## 5. Longest vs. Shortest Delivery Time

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

---

## 6. Runner Speed Trends

**Objective:** Calculate the average speed for each runner per delivery and identify trends.

```sql
SELECT 
    runner_id, 
    c.order_id, 
    COUNT(c.order_id) AS pizza_count, 
    (r.distance * 1000) AS distance_meter, 
    r.duration, 
    ROUND((r.distance * 1000 / r.duration), 2) AS avg_speed
FROM #runner_orders AS r
JOIN #customer_orders AS c
    ON r.order_id = c.order_id
WHERE r.distance != 0
GROUP BY runner_id, c.order_id, r.distance, r.duration
ORDER BY runner_id, pizza_count, avg_speed;
```

**Explanation:**
- Speed is calculated using distance and duration.
- Results are grouped and ordered for trend analysis.

**Improvement:** Add a visualization to showcase trends over time.

---

## 7. Successful Delivery Percentage

**Objective:** Determine the percentage of successful deliveries for each runner.

```sql
WITH delivery AS (
    SELECT 
        runner_id, 
        COUNT(order_id) AS total_delivery,
        SUM(CASE WHEN distance != 0 THEN 1 ELSE 0 END) AS successful_delivery
    FROM #runner_orders
    GROUP BY runner_id
)
SELECT 
    runner_id, 
    (successful_delivery * 100.0 / total_delivery) AS successful_delivery_perc
FROM delivery;
```

**Explanation:**
- Successful deliveries are identified where distance is not zero.
- Percentage is calculated as successful deliveries divided by total deliveries.

**Improvement:** Break down failed deliveries by reason to uncover issues.

---
**Suggestions for Further Analysis:**
- Implement predictive modeling to estimate delivery times based on historical data.
- Introduce clustering to segment runners based on performance metrics.
```

These changes include better sectioning, consistent formatting, and minor improvements for readability.
