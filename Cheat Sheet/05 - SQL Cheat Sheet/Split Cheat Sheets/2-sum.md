## **2. SUM()**  
🔹 **Purpose:** Returns the total sum of numeric values in a column. Used for calculating total revenue, sales, expenses, etc.  

📌 **Example 1: Total sales revenue from the `sales` table**  
```sql
SELECT SUM(amount) AS total_revenue
FROM sales;
```
🔹 **Output:**  
| total_revenue |
|--------------|
| 5,000,000    |

📌 **Example 2: Total salary paid to employees in the `employees` table**  
```sql
SELECT SUM(salary) AS total_salaries
FROM employees;
```
🔹 **Output:**  
| total_salaries |
|---------------|
| 12,500,000    |

📌 **Example 3: Total quantity of products sold by category**  
```sql
SELECT category, SUM(quantity) AS total_quantity_sold
FROM products
GROUP BY category;
```
🔹 **Output:**  
| category | total_quantity_sold |
|----------|--------------------|
| Electronics | 10,000           |
| Clothing    | 5,500            |