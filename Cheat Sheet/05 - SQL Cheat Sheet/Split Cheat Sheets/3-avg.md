## **3. AVG()**  
🔹 **Purpose:** Computes the average value of a numeric column. Useful for analyzing trends like **average order value, average salary, or customer spend.**  

📌 **Example 1: Calculate the average product price**  
```sql
SELECT AVG(price) AS average_price
FROM products;
```
🔹 **Output:**  
| average_price |
|--------------|
| 299.99       |

📌 **Example 2: Find the average salary by department**  
```sql
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;
```
🔹 **Output:**  
| department | avg_salary |
|------------|------------|
| HR         | 60,000     |
| IT         | 85,000     |

📌 **Example 3: Average revenue per order**  
```sql
SELECT AVG(amount) AS avg_order_value
FROM orders;
```
🔹 **Output:**  
| avg_order_value |
|---------------|
| 350.50       |