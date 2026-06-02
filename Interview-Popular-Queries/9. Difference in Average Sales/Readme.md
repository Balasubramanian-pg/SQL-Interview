# QUERY 9	
### Find difference in average sales

PROBLEM STATEMENT	Write a query to find the difference in average sales for each month of 2003 and 2004

![image](https://github.com/user-attachments/assets/5db15834-ac68-498a-b90d-416d48ad9561)

# SQL Query to Find Monthly Sales Difference Between 2003 and 2004

```sql
WITH monthly_sales_2003 AS (
    SELECT 
        month_id,
        AVG(sales) AS avg_sales_2003
    FROM orders
    WHERE year_id = 2003
    GROUP BY month_id
),
monthly_sales_2004 AS (
    SELECT 
        month_id,
        AVG(sales) AS avg_sales_2004
    FROM orders
    WHERE year_id = 2004
    GROUP BY month_id
)
SELECT 
    COALESCE(m03.month_id, m04.month_id) AS month,
    m03.avg_sales_2003,
    m04.avg_sales_2004,
    ROUND(COALESCE(m04.avg_sales_2004, 0) - COALESCE(m03.avg_sales_2003, 0), 2) AS sales_difference
FROM 
    monthly_sales_2003 m03
FULL OUTER JOIN 
    monthly_sales_2004 m04 ON m03.month_id = m04.month_id
ORDER BY 
    month;
```
