Below is a cheat sheet highlighting some of the most important SQL functions along with their uses and small examples:

---

### Aggregate Functions

- **COUNT()**  
  **Use:** Returns the number of rows in a dataset.  
  **Example:**  
  ```sql
  SELECT COUNT(*) AS total_orders
  FROM orders;
  ```

- **SUM()**  
  **Use:** Calculates the total sum of a numeric column.  
  **Example:**  
  ```sql
  SELECT SUM(amount) AS total_sales
  FROM sales;
  ```

- **AVG()**  
  **Use:** Computes the average of a numeric column.  
  **Example:**  
  ```sql
  SELECT AVG(salary) AS average_salary
  FROM employees;
  ```

- **MIN()**  
  **Use:** Retrieves the minimum value in a column.  
  **Example:**  
  ```sql
  SELECT MIN(price) AS lowest_price
  FROM products;
  ```

- **MAX()**  
  **Use:** Retrieves the maximum value in a column.  
  **Example:**  
  ```sql
  SELECT MAX(price) AS highest_price
  FROM products;
  ```

---

### String Functions

- **CONCAT()**  
  **Use:** Combines two or more strings into one.  
  **Example:**  
  ```sql
  SELECT CONCAT(first_name, ' ', last_name) AS full_name
  FROM employees;
  ```

- **SUBSTRING()**  
  **Use:** Extracts a portion of a string.  
  **Example:**  
  ```sql
  SELECT SUBSTRING('Hello SQL', 1, 5) AS greeting;  -- returns 'Hello'
  ```

- **UPPER() / LOWER()**  
  **Use:** Converts a string to uppercase or lowercase.  
  **Example:**  
  ```sql
  SELECT UPPER('hello') AS shout, LOWER('WORLD') AS whisper;
  ```

- **LENGTH() / LEN()**  
  **Use:** Returns the length of a string (use `LEN()` in SQL Server).  
  **Example:**  
  ```sql
  SELECT LENGTH('Hello') AS str_length;  -- returns 5
  ```

- **TRIM()**  
  **Use:** Removes leading and trailing spaces from a string.  
  **Example:**  
  ```sql
  SELECT TRIM('  spaced out  ') AS trimmed;
  ```

---

### Date Functions

- **NOW() / CURRENT_TIMESTAMP**  
  **Use:** Returns the current date and time.  
  **Example:**  
  ```sql
  SELECT NOW() AS current_datetime;
  ```

- **CURDATE()**  
  **Use:** Returns the current date (commonly used in MySQL).  
  **Example:**  
  ```sql
  SELECT CURDATE() AS today;
  ```

- **DATEADD()**  
  **Use:** Adds a specified time interval to a date (syntax varies by SQL dialect; SQL Server example).  
  **Example:**  
  ```sql
  SELECT DATEADD(day, 7, GETDATE()) AS next_week;
  ```

- **DATEDIFF()**  
  **Use:** Calculates the difference between two dates.  
  **Example:**  
  ```sql
  SELECT DATEDIFF('2025-01-01', '2024-12-25') AS days_difference;
  ```

---

### Conditional and Conversion Functions

- **COALESCE()**  
  **Use:** Returns the first non-null value in a list.  
  **Example:**  
  ```sql
  SELECT COALESCE(NULL, 'default') AS result;  -- returns 'default'
  ```

- **IFNULL()** (MySQL)  
  **Use:** Returns an alternative value if a given expression is NULL.  
  **Example:**  
  ```sql
  SELECT IFNULL(discount, 0) AS discount_value
  FROM orders;
  ```

- **CASE**  
  **Use:** Provides conditional logic within queries.  
  **Example:**  
  ```sql
  SELECT 
    product_name,
    CASE 
      WHEN stock = 0 THEN 'Out of Stock'
      ELSE 'In Stock'
    END AS availability
  FROM products;
  ```

---

### Mathematical Functions

- **ROUND()**  
  **Use:** Rounds a numeric value to a specified number of decimal places.  
  **Example:**  
  ```sql
  SELECT ROUND(123.456, 2) AS rounded_value;  -- returns 123.46
  ```

- **ABS()**  
  **Use:** Returns the absolute (non-negative) value of a number.  
  **Example:**  
  ```sql
  SELECT ABS(-10) AS absolute_value;  -- returns 10
  ```

---

This cheat sheet covers key functions you'll frequently use in SQL. Each function can be further customized based on your specific database system and requirements. Happy querying!
