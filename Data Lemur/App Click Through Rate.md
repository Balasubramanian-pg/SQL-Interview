## Question

This is the same question as problem #1 in the SQL Chapter of Ace the Data Science Interview!

Assume you have an `events` table on Facebook app analytics. Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.

**Definition and note:**

> Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
> To avoid integer division, multiply the CTR by 100.0, not 100.

**`events` Table:**

| Column Name | Type     |
|-------------|----------|
| app_id      | integer  |
| event_type  | string   |
| timestamp   | datetime |

**`events` Example Input:**

| app_id | event_type   | timestamp             |
|--------|--------------|-----------------------|
| 123    | impression   | 07/18/2022 11:36:12   |
| 123    | impression   | 07/18/2022 11:37:12   |
| 123    | click        | 07/18/2022 11:37:42   |
| 234    | impression   | 07/18/2022 14:15:12   |
| 234    | click        | 07/18/2022 14:16:12   |

**Example Output:**

| app_id | ctr   |
|--------|-------|
| 123    | 50.00 |
| 234    | 100.00|

**Explanation**

Let's consider an example of App 123. This app has a click-through rate (CTR) of 50.00% because out of the 2 impressions it received, it got 1 click.

To calculate the CTR, we divide the number of clicks by the number of impressions, and then multiply the result by 100.0 to express it as a percentage. In this case, 1 divided by 2 equals 0.5, and when multiplied by 100.0, it becomes 50.00%. So, the CTR of App 123 is 50.00%.

*The dataset you are querying against may have different input & output - this is just an example!*

To calculate the click-through rate (CTR) for each app in the year 2022, you can use the following SQL query. This query will filter the events to include only those from the year 2022, count the number of impressions and clicks for each app, and then calculate the CTR as specified.

Here's the SQL query to achieve this:

```sql
SELECT
    app_id,
    ROUND(100.0 * SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END), 0), 2) AS ctr
FROM
    events
WHERE
    EXTRACT('Year' FROM timestamp) = 2022
GROUP BY
    app_id;
```

### Explanation:

1. **Filtering Events for 2022**: The `WHERE YEAR(timestamp) = 2022` clause ensures that only events from the year 2022 are considered.

2. **Counting Clicks and Impressions**:
   - `SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END)` counts the number of clicks.
   - `SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END)` counts the number of impressions.

3. **Calculating CTR**:
   - The CTR is calculated as `100.0 * (number of clicks) / (number of impressions)`.
   - `NULLIF` is used to handle the case where there are no impressions, avoiding division by zero.

4. **Rounding the Result**: The `ROUND` function is used to round the CTR to 2 decimal places.

5. **Grouping by App ID**: The `GROUP BY app_id` clause ensures that the CTR is calculated for each app individually.

This query will give you the CTR for each app in the year 2022, rounded to 2 decimal places.
