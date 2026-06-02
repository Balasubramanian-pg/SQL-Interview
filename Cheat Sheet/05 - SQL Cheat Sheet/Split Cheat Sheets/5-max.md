## **5. MAX()**  
🔹 **Purpose:** Retrieves the largest (maximum) value in a column. Commonly used to find **highest revenue, peak sales, most expensive items, latest dates, etc.**  

📌 **Example 1: Find the most expensive product**  
```sql
SELECT MAX(price) AS highest_price
FROM products;
```
🔹 **Output:**  
| highest_price |
|-------------|
| 1999.99     |

📌 **Example 2: Find the latest order date**  
```sql
SELECT MAX(order_date) AS last_order_date
FROM orders;
```
🔹 **Output:**  
| last_order_date |
|---------------|
| 2024-03-22   |

📌 **Example 3: Find the maximum salary in the `employees` table**  
```sql
SELECT MAX(salary) AS highest_salary
FROM employees;
```
🔹 **Output:**  
| highest_salary |
|--------------|
| 250,000      |