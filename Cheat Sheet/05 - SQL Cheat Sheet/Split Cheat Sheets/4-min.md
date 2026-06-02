## **4. MIN()**  
🔹 **Purpose:** Retrieves the smallest (minimum) value in a column. Useful for identifying **lowest prices, minimum salaries, earliest dates, etc.**  

📌 **Example 1: Find the lowest product price**  
```sql
SELECT MIN(price) AS lowest_price
FROM products;
```
🔹 **Output:**  
| lowest_price |
|-------------|
| 5.99        |

📌 **Example 2: Find the earliest order date in the `orders` table**  
```sql
SELECT MIN(order_date) AS first_order_date
FROM orders;
```
🔹 **Output:**  
| first_order_date |
|-----------------|
| 2020-01-15      |

📌 **Example 3: Find the minimum salary in the `employees` table**  
```sql
SELECT MIN(salary) AS lowest_salary
FROM employees;
```
🔹 **Output:**  
| lowest_salary |
|-------------|
| 45,000      |