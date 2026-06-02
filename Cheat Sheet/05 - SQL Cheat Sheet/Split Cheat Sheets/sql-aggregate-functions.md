# **SQL Aggregate Functions**

Aggregate functions perform calculations on multiple rows of data and return a single value. They are commonly used in **reporting, analytics, and summarizing data** in SQL queries.  

## **1. COUNT()**  
🔹 **Purpose:** Returns the number of rows that match a specified condition. Often used to count the total number of records in a table or within a group.  

📌 **Example 1: Count total orders in the `orders` table**  
```sql
SELECT COUNT(*) AS total_orders
FROM orders;
```
🔹 **Output:**  
| total_orders |
|-------------|
| 1500        |

📌 **Example 2: Count orders placed by a specific customer (`customer_id = 101`)**  
```sql
SELECT COUNT(*) AS customer_orders
FROM orders
WHERE customer_id = 101;
```
🔹 **Output:**  
| customer_orders |
|----------------|
| 25             |

📌 **Example 3: Count distinct products sold**  
```sql
SELECT COUNT(DISTINCT product_id) AS unique_products_sold
FROM sales;
```
🔹 **Output:**  
| unique_products_sold |
|----------------------|
| 320                  |