This is the same question as problem #2 in the SQL Chapter of Ace the Data Science Interview!

Assume you're given the tables containing completed trade orders and user details in a Robinhood trading system.

Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order. Output the city name and the corresponding number of completed trade orders.
trades Table:
Column Name	Type
order_id	integer
user_id	integer
quantity	integer
status	string ('Completed', 'Cancelled')
date	timestamp
price	decimal (5, 2)
trades Example Input:
order_id	user_id	quantity	status	date	price
100101	111	10	Cancelled	08/17/2022 12:00:00	9.80
100102	111	10	Completed	08/17/2022 12:00:00	10.00
100259	148	35	Completed	08/25/2022 12:00:00	5.10
100264	148	40	Completed	08/26/2022 12:00:00	4.80
100305	300	15	Completed	09/05/2022 12:00:00	10.00
100400	178	32	Completed	09/17/2022 12:00:00	12.00
100565	265	2	Completed	09/27/2022 12:00:00	8.70
users Table:
Column Name	Type
user_id	integer
city	string
email	string
signup_date	datetime
users Example Input:
user_id	city	email	signup_date
111	San Francisco	rrok10@gmail.com	08/03/2021 12:00:00
148	Boston	sailor9820@gmail.com	08/20/2021 12:00:00
178	San Francisco	harrypotterfan182@gmail.com	01/05/2022 12:00:00
265	Denver	shadower_@hotmail.com	02/26/2022 12:00:00
300	San Francisco	houstoncowboy1122@hotmail.com	06/30/2022 12:00:00
Example Output:
city	total_orders
San Francisco	3
Boston	2
Denver	1

In the given dataset, San Francisco has the highest number of completed trade orders with 3 orders. Boston holds the second position with 2 orders, and Denver ranks third with 1 order.

The dataset you are querying against may have different input & output - this is just an example!

Here's the SQL query that retrieves the **top three cities** with the highest number of **completed trade orders**, ordered in descending order:

```sql
SELECT 
    u.city,
    COUNT(*) AS total_orders
FROM trades t
JOIN users u
    ON t.user_id = u.user_id
WHERE t.status = 'Completed'
GROUP BY u.city
ORDER BY total_orders DESC
LIMIT 3;
```

### 🔍 Explanation:
- **JOIN** the `trades` and `users` tables using `user_id` to connect each trade with its user's city.
- **Filter** for only `Completed` trades using `WHERE t.status = 'Completed'`.
- **Group by** `city` and **count** the number of trades.
- **Order by** the count in descending order.
- Use `LIMIT 3` to get the top 3 cities.

Let me know if you want to see how this would change with variations like ranking ties or using window functions!
