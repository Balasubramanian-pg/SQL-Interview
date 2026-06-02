

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
