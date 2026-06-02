PROBLEM STATEMENT	A pizza company is taking orders from customers, and each pizza ordered is added to their database as a separate order.	
	Each order has an associated status, "CREATED or SUBMITTED or DELIVERED'. 	
	An order's Final_ Status is calculated based on status as follows:	
		1. When all orders for a customer have a status of DELIVERED, that customer's order has a Final_Status of COMPLETED.
		2. If a customer has some orders that are not DELIVERED and some orders that are DELIVERED, the Final_ Status is IN PROGRESS.
		3. If all of a customer's orders are SUBMITTED, the Final_Status is AWAITING PROGRESS.
		4. Otherwise, the Final Status is AWAITING SUBMISSION.
		
	Write a query to report the customer_name and Final_Status of each customer's arder. Order the results by customer	
	name.	

![image](https://github.com/user-attachments/assets/c21f9669-6e42-449b-9d24-f200ba323688)

# SQL Query for Pizza Delivery Status Report

```sql
WITH customer_status AS (
    SELECT 
        cust_name,
        SUM(CASE WHEN status = 'DELIVERED' THEN 1 ELSE 0 END) AS delivered_count,
        SUM(CASE WHEN status = 'SUBMITTED' THEN 1 ELSE 0 END) AS submitted_count,
        SUM(CASE WHEN status = 'CREATED' THEN 1 ELSE 0 END) AS created_count,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY cust_name
)
SELECT 
    cust_name AS customer_name,
    CASE 
        WHEN delivered_count = total_orders THEN 'COMPLETED'
        WHEN delivered_count > 0 AND (submitted_count > 0 OR created_count > 0) THEN 'IN PROGRESS'
        WHEN submitted_count = total_orders AND created_count = 0 THEN 'AWAITING PROGRESS'
        ELSE 'AWAITING SUBMISSION'
    END AS Final_Status
FROM customer_status
ORDER BY cust_name;
```

## Expected Output:

```
customer_name | Final_Status
--------------|-------------
David         | IN PROGRESS
John          | COMPLETED
Krish         | AWAITING SUBMISSION
Smith         | AWAITING PROGRESS
```

## Explanation:

1. The CTE `customer_status` calculates counts of each status type per customer:
   - `delivered_count`: Number of DELIVERED orders
   - `submitted_count`: Number of SUBMITTED orders
   - `created_count`: Number of CREATED orders
   - `total_orders`: Total orders per customer

2. The main query then applies the business rules:
   - COMPLETED: When all orders are DELIVERED (John)
   - IN PROGRESS: When some orders are DELIVERED and others aren't (David)
   - AWAITING PROGRESS: When all orders are SUBMITTED (Smith)
   - AWAITING SUBMISSION: Default case (Krish)

3. Results are ordered alphabetically by customer name.
