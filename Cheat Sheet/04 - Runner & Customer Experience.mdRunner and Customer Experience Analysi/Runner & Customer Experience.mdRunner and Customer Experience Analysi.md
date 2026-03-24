# Runner and Customer Experience Analysis

This document provides detailed SQL queries and explanations to analyze various aspects of the runner and customer experience. Each query is thoroughly commented, and visual aids are included to simplify understanding.

---

## 1. Weekly Runner Signups

**Objective:** Determine how many runners signed up during each one-week period starting from January 1, 2021.

```sql
SELECT 
    runner_id,
    CASE
        WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-07' THEN 'Week 1'
        WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-14' THEN 'Week 2'
        ELSE 'Week 3'
    END AS runner_signups
FROM runners
GROUP BY registration_date, runner_id;
```

**Explanation:**
- The `CASE` statement segments the registration dates into weekly periods.
- Each runner ID is grouped by the registration date to count signups per week.

**Improvement:** Using a dynamic date function for flexible periods would make the query more reusable.

---

## 2. Average Arrival Time to HQ

**Objective:** Calculate the average time (in minutes) it takes runners to arrive at Pizza Runner HQ to pick up orders.

```sql
WITH time_taken AS (
    SELECT 
        r.runner_id, 
        c.order_id, 
        c.order_time, 
        r.pickup_time, 
        DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS mins_taken_to_arrive_HQ
    FROM #customer_orders AS c
    JOIN #runner_orders AS r
        ON c.order_id = r.order_id
    WHERE r.distance != 0
)
SELECT 
    runner_id, 
    AVG(mins_taken_to_arrive_HQ) AS avg_mins_taken_to_arrive_HQ
FROM time_taken
WHERE mins_taken_to_arrive_HQ > 1
GROUP BY runner_id;
```

**Explanation:**
- The `DATEDIFF` function calculates the time difference in minutes between order and pickup times.
- The `WHERE` clause ensures only valid distances and meaningful data are included.
- Averages are calculated for each runner.

**Improvement:** Consider filtering out outliers (e.g., extremely high times) to avoid skewed averages.

---

## 3. Correlation Between Pizza Count and Preparation Time

**Objective:** Examine if there's a relationship between the number of pizzas ordered and preparation time.

```sql
WITH prepare_time AS (
    SELECT 
        c.order_id, 
        COUNT(c.order_id) AS no_pizza_ordered, 
        c.order_time, 
        r.pickup_time, 
        DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_taken_to_prepare
    FROM #customer_orders AS c
    JOIN #runner_orders AS r
        ON c.order_id = r.order_id
    WHERE r.distance != 0
    GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT 
    no_pizza_ordered, 
    AVG(time_taken_to_prepare) AS avg_time_to_prepare
FROM prepare_time
WHERE time_taken_to_prepare > 1
GROUP BY no_pizza_ordered;
```

**Explanation:**
- The `COUNT` function determines the number of pizzas ordered per order.
- The `DATEDIFF` calculates the time taken to prepare the orders.
- Averages are grouped by the number of pizzas ordered.

**Improvement:** Adding a statistical test (e.g., correlation coefficient) can quantify the relationship.

---

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
