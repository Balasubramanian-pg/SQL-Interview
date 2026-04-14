Below is a cheat sheet highlighting some of the most important SQL functions along with their uses and small examples:

---
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

---

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

---

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

---

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

---

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

---

## **Conclusion**  
SQL aggregate functions are essential for summarizing and analyzing data efficiently. They help extract valuable insights like **total revenue, average order value, highest sales, and more.** When combined with `GROUP BY` and `HAVING` clauses, they become even more powerful for detailed reporting and business intelligence.  

✅ **Key Takeaways:**  
- `COUNT()` → Count records, distinct values  
- `SUM()` → Total sum of numeric values  
- `AVG()` → Compute average value  
- `MIN()` → Retrieve the smallest value  
- `MAX()` → Retrieve the largest value  

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



Below is an advanced SQL cheat sheet covering additional features beyond basic functions. This guide includes essential SQL concepts with brief explanations and small examples:

---

## 1. Joins  
**Purpose:** Combine rows from two or more tables based on a related column.

- **INNER JOIN** – Returns rows with matching values in both tables.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  INNER JOIN tableB b ON a.common_field = b.common_field;
  ```

- **LEFT JOIN** – Returns all rows from the left table, and the matched rows from the right table.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  LEFT JOIN tableB b ON a.common_field = b.common_field;
  ```

- **RIGHT JOIN** – Returns all rows from the right table, and the matched rows from the left table.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  RIGHT JOIN tableB b ON a.common_field = b.common_field;
  ```

- **FULL OUTER JOIN** – Returns rows when there is a match in one of the tables.
  ```sql
  SELECT a.column1, b.column2
  FROM tableA a
  FULL OUTER JOIN tableB b ON a.common_field = b.common_field;
  ```

---

## 2. Subqueries  
**Purpose:** Use a query inside another query to further refine your data.

- **Example:**
  ```sql
  SELECT employee_name
  FROM employees
  WHERE department_id IN (
      SELECT department_id
      FROM departments
      WHERE location = 'NY'
  );
  ```

---

## 3. Common Table Expressions (CTE)  
**Purpose:** Create a temporary result set that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement.

- **Example:**
  ```sql
  WITH SalesCTE AS (
      SELECT salesperson, SUM(sales) AS total_sales
      FROM sales
      GROUP BY salesperson
  )
  SELECT *
  FROM SalesCTE
  WHERE total_sales > 10000;
  ```

---

## 4. Window Functions  
**Purpose:** Perform calculations across a set of rows related to the current row, without collapsing the result set.

- **Example (Ranking Salaries):**
  ```sql
  SELECT employee_name, salary,
         RANK() OVER (ORDER BY salary DESC) AS salary_rank
  FROM employees;
  ```

---

## 5. Views  
**Purpose:** Create virtual tables based on the result of a SELECT query. Views simplify complex queries and can provide a layer of security.

- **Example:**
  ```sql
  CREATE VIEW ActiveCustomers AS
  SELECT customer_id, customer_name
  FROM customers
  WHERE active = 1;
  ```

---

## 6. Indexes  
**Purpose:** Improve query performance by creating pointers to data in a table.

- **Example:**
  ```sql
  CREATE INDEX idx_customer_name
  ON customers(customer_name);
  ```

---

## 7. Stored Procedures & Functions  
**Purpose:** Encapsulate a series of SQL statements for reuse. Procedures perform actions, while functions return a value.

- **Stored Procedure Example:**
  ```sql
  CREATE PROCEDURE GetEmployeeByDept (@dept_id INT)
  AS
  BEGIN
      SELECT employee_name, salary
      FROM employees
      WHERE department_id = @dept_id;
  END;
  ```
- **Function Example (SQL Server):**
  ```sql
  CREATE FUNCTION dbo.GetFullName (@first NVARCHAR(50), @last NVARCHAR(50))
  RETURNS NVARCHAR(101)
  AS
  BEGIN
      RETURN CONCAT(@first, ' ', @last);
  END;
  ```

---

## 8. Triggers  
**Purpose:** Automatically execute SQL code in response to certain events on a table, such as INSERT, UPDATE, or DELETE operations.

- **Example:**
  ```sql
  CREATE TRIGGER trg_AfterInsert
  ON orders
  AFTER INSERT
  AS
  BEGIN
      PRINT 'A new order has been inserted.';
  END;
  ```

---

## 9. Transactions  
**Purpose:** Ensure a sequence of SQL statements are executed as a single unit, maintaining data integrity.

- **Example:**
  ```sql
  BEGIN TRANSACTION;
      UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
      UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
  COMMIT;
  ```

---

## 10. Set Operations  
**Purpose:** Combine results from multiple SELECT queries.

- **UNION** – Combines results and removes duplicates.
  ```sql
  SELECT column_name FROM tableA
  UNION
  SELECT column_name FROM tableB;
  ```
- **INTERSECT** – Returns only the common records.
  ```sql
  SELECT column_name FROM tableA
  INTERSECT
  SELECT column_name FROM tableB;
  ```
- **EXCEPT (or MINUS)** – Returns records from the first query that aren’t in the second.
  ```sql
  SELECT column_name FROM tableA
  EXCEPT
  SELECT column_name FROM tableB;
  ```

---

This advanced cheat sheet covers a broad range of SQL features to help you manage and manipulate data more effectively. Each section provides a quick reference to the purpose of the feature along with a concise example to illustrate its use. Enjoy exploring these powerful SQL capabilities!



Below is a cheat sheet featuring additional advanced SQL features to further enhance your querying capabilities:

---

## 1. Recursive Common Table Expressions (CTEs)
**Purpose:** Query hierarchical or recursive data such as organizational charts or folder structures.

**Example (SQL Server / PostgreSQL):**
```sql
WITH EmployeeHierarchy AS (
    SELECT employee_id, manager_id, employee_name
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.employee_name
    FROM employees e
    INNER JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM EmployeeHierarchy;
```
*This recursive CTE starts with top-level employees and then recursively joins to retrieve all subordinate employees.*

---

## 2. Pivoting Data
**Purpose:** Transform row data into columns for a more intuitive summary or report.

**Example (SQL Server using PIVOT):**
```sql
SELECT *
FROM (
    SELECT year, month, sales
    FROM SalesData
) AS SourceTable
PIVOT (
    SUM(sales)
    FOR month IN ([Jan], [Feb], [Mar])
) AS PivotTable;
```
*This query converts monthly sales rows into columns for January, February, and March.*

---

## 3. Dynamic SQL
**Purpose:** Build and execute SQL queries dynamically at runtime, which is useful when table names or conditions vary.

**Example (SQL Server):**
```sql
DECLARE @sql NVARCHAR(4000);
DECLARE @TableName NVARCHAR(100) = 'Orders';
SET @sql = 'SELECT * FROM ' + QUOTENAME(@TableName);
EXEC sp_executesql @sql;
```
*This example constructs a SQL statement using a variable for the table name and executes it safely.*

---

## 4. Temporary Tables and Table Variables
**Purpose:** Store intermediate results temporarily during complex query processing.

**Example (Temporary Table in MySQL):**
```sql
CREATE TEMPORARY TABLE TempSales (
    sale_id INT,
    sale_amount DECIMAL(10,2)
);

INSERT INTO TempSales (sale_id, sale_amount) VALUES (1, 100.00);
SELECT * FROM TempSales;
```
*Temporary tables exist only for the duration of your session, allowing you to break down complex operations.*

---

## 5. JSON Functions
**Purpose:** Parse, query, and generate JSON data directly within your SQL queries.

**Example (MySQL):**
```sql
SELECT JSON_EXTRACT(json_column, '$.name') AS name
FROM json_table;
```
*This extracts the `name` field from a JSON column, making it easier to work with JSON data stored in your database.*

---

## 6. Spatial Data Functions
**Purpose:** Work with geographic and geometric data for applications like mapping or spatial analysis.

**Example (PostGIS for PostgreSQL):**
```sql
SELECT ST_AsText(geom) AS geometry
FROM spatial_table;
```
*This converts spatial geometry data into a human-readable text format.*

---

## 7. Query Hints and Optimization
**Purpose:** Influence the query optimizer's behavior to improve performance in specific scenarios.

**Example (SQL Server):**
```sql
SELECT * 
FROM Orders WITH (NOLOCK)
WHERE order_date > '2024-01-01';
```
*The `NOLOCK` hint can help reduce locking contention by reading uncommitted data (use with caution).*

---

## 8. Grouping Sets, ROLLUP, and CUBE
**Purpose:** Perform multi-level aggregations to produce summary reports with subtotals and grand totals.

**Example (ROLLUP in MySQL):**
```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department WITH ROLLUP;
```
*This query returns a row for each department along with an extra row that shows the overall total count.*

---

Below is a further advanced SQL cheat sheet highlighting additional powerful SQL techniques and features:

---

## 9. Advanced Window Functions  
**Purpose:** Retrieve values from rows before or after the current row without collapsing the result set.

- **LEAD() and LAG()**  
  **Example:**
  ```sql
  SELECT
      employee_name,
      salary,
      LAG(salary, 1) OVER (ORDER BY salary) AS previous_salary,
      LEAD(salary, 1) OVER (ORDER BY salary) AS next_salary
  FROM employees;
  ```
  *This returns the previous and next salary relative to each employee's salary.*

- **FIRST_VALUE() and LAST_VALUE()**  
  **Example:**
  ```sql
  SELECT
      employee_name,
      salary,
      FIRST_VALUE(salary) OVER (ORDER BY salary DESC) AS highest_salary,
      LAST_VALUE(salary) OVER (ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_salary
  FROM employees;
  ```
  *These functions fetch the first and last values in a window, respectively.*

---

## 10. Full-Text Search  
**Purpose:** Perform efficient text searches on large text columns.

- **Example (SQL Server):**
  ```sql
  SELECT *
  FROM articles
  WHERE CONTAINS(content, 'database');
  ```
  *This query searches for the term "database" within the `content` column.*

---

## 11. Table Partitioning  
**Purpose:** Divide large tables into smaller, more manageable pieces to improve performance and maintenance.

- **Example (MySQL Range Partitioning):**
  ```sql
  CREATE TABLE orders (
      order_id INT,
      order_date DATE,
      amount DECIMAL(10,2)
  )
  PARTITION BY RANGE (YEAR(order_date)) (
      PARTITION p2019 VALUES LESS THAN (2020),
      PARTITION p2020 VALUES LESS THAN (2021),
      PARTITION p2021 VALUES LESS THAN (2022)
  );
  ```
  *This partitions the `orders` table by year, making queries on specific date ranges more efficient.*

---

## 12. Materialized Views  
**Purpose:** Store the result of a query physically to speed up retrieval for complex or resource-intensive queries.

- **Example (Oracle):**
  ```sql
  CREATE MATERIALIZED VIEW sales_summary AS
  SELECT salesperson, SUM(sales) AS total_sales
  FROM sales
  GROUP BY salesperson;
  ```
  *Materialized views can be refreshed periodically to provide up-to-date aggregated data.*

---

## 13. Error Handling with TRY/CATCH  
**Purpose:** Capture and handle errors in SQL code, especially within stored procedures.

- **Example (SQL Server):**
  ```sql
  BEGIN TRY
      -- Statements that might cause an error
      UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
  END TRY
  BEGIN CATCH
      PRINT 'An error occurred: ' + ERROR_MESSAGE();
  END CATCH;
  ```
  *This structure catches errors and provides a mechanism to handle them gracefully.*

---

## 14. Hierarchical Queries (Oracle CONNECT BY)  
**Purpose:** Retrieve and display hierarchical data (e.g., organizational structures).

- **Example (Oracle):**
  ```sql
  SELECT employee_id, employee_name, manager_id
  FROM employees
  START WITH manager_id IS NULL
  CONNECT BY PRIOR employee_id = manager_id;
  ```
  *This query builds an organizational hierarchy starting from top-level employees (with no manager).*

---

## 15. Optimizing Index Usage and Maintenance  
**Purpose:** Enhance query performance by creating, analyzing, and maintaining indexes.

- **Creating a Composite Index:**
  ```sql
  CREATE INDEX idx_customer_order ON orders(customer_id, order_date);
  ```
  *A composite index can speed up queries filtering on both `customer_id` and `order_date`.*

- **Rebuilding an Index (SQL Server):**
  ```sql
  ALTER INDEX idx_customer_order ON orders REBUILD;
  ```
  *Regular index maintenance (like rebuilding) ensures optimal performance.*

---

Below are even more advanced SQL features to expand your toolkit:

---

## 16. MERGE / UPSERT  
**Purpose:** Combine insert, update, and delete operations in one atomic statement, which is useful for synchronizing tables.

**Example (SQL Server):**
```sql
MERGE target_table AS target
USING source_table AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET target.value = source.value
WHEN NOT MATCHED BY TARGET THEN
    INSERT (id, value) VALUES (source.id, source.value)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
```
*This statement updates matching records, inserts new ones, and deletes records not present in the source.*

---

## 17. Cursors  
**Purpose:** Process query results row by row when set-based operations aren’t suitable.

**Example (SQL Server):**
```sql
DECLARE @value INT;

DECLARE cursor_example CURSOR FOR
SELECT column_name FROM table_name;

OPEN cursor_example;
FETCH NEXT FROM cursor_example INTO @value;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Process each row individually
    PRINT @value;
    FETCH NEXT FROM cursor_example INTO @value;
END;

CLOSE cursor_example;
DEALLOCATE cursor_example;
```
*Use cursors sparingly, as set-based operations are typically more efficient.*

---

## 18. Batch Processing & Scripting  
**Purpose:** Execute multiple SQL statements as a single unit or batch.

**Example (T-SQL):**
```sql
-- This batch creates a temporary table, inserts data, and selects from it.
CREATE TABLE #TempData (id INT, value VARCHAR(50));

INSERT INTO #TempData (id, value)
VALUES (1, 'A'), (2, 'B');

SELECT * FROM #TempData;
GO  -- Marks the end of a batch in SQL Server.
```
*Batches can help organize scripts and control execution flow.*

---

## 19. Advanced Data Types  
**Purpose:** Leverage specialized types for complex data such as XML, arrays, or geospatial data.

- **XML:**  
  **Example (SQL Server):**
  ```sql
  DECLARE @xml XML = '<root><item id="1">Value</item></root>';
  SELECT @xml.value('(/root/item/@id)[1]', 'INT') AS ItemID;
  ```
  
- **Arrays (PostgreSQL):**  
  **Example:**
  ```sql
  SELECT ARRAY[1, 2, 3] AS numbers;
  ```

*Using these types can simplify the storage and querying of structured data.*

---

## 20. Security, Roles & Encryption  
**Purpose:** Manage access, permissions, and protect data within the database.

- **Roles & Permissions:**  
  **Example (PostgreSQL):**
  ```sql
  CREATE ROLE read_only;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
  ```
- **Encryption:**  
  Some databases offer built-in encryption features for data-at-rest or during transmission (e.g., Transparent Data Encryption in SQL Server).

*Properly managing security is critical for safeguarding data integrity and privacy.*

---

## 21. Query Execution Plans & Optimization Tools  
**Purpose:** Analyze and optimize query performance by reviewing how the database executes SQL statements.

- **EXPLAIN (MySQL/PostgreSQL):**
  ```sql
  EXPLAIN SELECT * FROM orders WHERE customer_id = 123;
  ```
  *This provides insights into index usage, joins, and potential bottlenecks.*

- **Execution Plan Analysis (SQL Server):**
  ```sql
  SET SHOWPLAN_ALL ON;
  SELECT * FROM orders WHERE customer_id = 123;
  SET SHOWPLAN_ALL OFF;
  ```
*Understanding execution plans helps you fine-tune your queries for better performance.*

---

Here are even more advanced SQL features that can take your skills to the next level:

---

## 22. Temporal Tables (System-Versioned Tables)
**Purpose:** Automatically track and store the full history of data changes over time, enabling you to query data as it was at any point in time.

**Example (SQL Server):**
```sql
CREATE TABLE EmployeeHistory (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Salary DECIMAL(10,2),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistoryHistory));
```

---

## 23. Graph Queries
**Purpose:** Model and query complex many-to-many relationships (such as social networks or recommendation systems) using node and edge tables.

**Example (SQL Server):**
```sql
-- Create node table for persons
CREATE TABLE Person (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
) AS NODE;

-- Create edge table for friendships
CREATE TABLE Friendship (
    $from_id INT,
    $to_id INT
) AS EDGE;

-- Query to find a person's friends:
SELECT p.Name, f.$to_id
FROM Person p
JOIN Friendship f ON p.ID = f.$from_id;
```

---

## 24. External Tables / PolyBase
**Purpose:** Query data stored in external sources (like Hadoop, Azure Blob Storage, or flat files) as if it were in your local database.

**Example (SQL Server with PolyBase):**
```sql
CREATE EXTERNAL TABLE ExternalSales (
    SaleID INT,
    Amount DECIMAL(10,2)
)
WITH (
    LOCATION = 'externaldata/sales/',
    DATA_SOURCE = MyExternalDataSource,
    FILE_FORMAT = MyFileFormat
);
```

---

## 25. Row-Level Security
**Purpose:** Enforce fine-grained access control by restricting which rows a user can view or modify.

**Example (SQL Server):**
```sql
-- Create a predicate function:
CREATE FUNCTION dbo.fn_securitypredicate(@CustomerID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS fn_securitypredicate_result
           WHERE @CustomerID = CAST(SESSION_CONTEXT(N'CustomerID') AS INT);

-- Apply the security policy on the Sales table:
CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE dbo.fn_securitypredicate(CustomerID)
ON dbo.Sales
WITH (STATE = ON);
```

---

## 26. Change Data Capture (CDC) / Change Tracking
**Purpose:** Track changes made to tables over time so you can capture data modifications for auditing or incremental data processing.

**Example (SQL Server CDC):**
```sql
EXEC sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name   = 'Sales', 
    @role_name     = NULL;
```

---

## 27. Columnstore Indexes
**Purpose:** Improve the performance of analytical queries by storing data in a columnar format rather than row-based, which is particularly effective for large data warehouses.

**Example (SQL Server):**
```sql
CREATE COLUMNSTORE INDEX idx_ColumnStore
ON Sales (SaleID, Amount);
```

---

## 28. In-Memory OLTP
**Purpose:** Dramatically boost transaction processing performance by storing and managing data in memory-optimized tables.

**Example (SQL Server):**
```sql
CREATE TABLE InMemorySales (
    SaleID INT NOT NULL PRIMARY KEY NONCLUSTERED,
    Amount DECIMAL(10,2)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
```

---

## 29. Data Compression
**Purpose:** Reduce the storage footprint of your data and potentially improve I/O performance through row-level or page-level compression.

**Example (SQL Server):**
```sql
ALTER TABLE Sales 
REBUILD PARTITION = ALL 
WITH (DATA_COMPRESSION = PAGE);
```

---

## 30. Extended Events
**Purpose:** Monitor, diagnose, and troubleshoot performance and other issues in SQL Server by capturing detailed event data.

**Example (SQL Server):**
```sql
CREATE EVENT SESSION QueryMonitor ON SERVER 
ADD EVENT sqlserver.sql_statement_completed
ADD TARGET package0.event_file(SET filename = N'QueryMonitor.xel');
ALTER EVENT SESSION QueryMonitor ON SERVER STATE = START;
```

---

Below are additional advanced SQL features (items 31–35) to further enhance your database management and optimization skills:

---

## 31. Database Replication and Mirroring  
**Purpose:**  
Enable high availability and redundancy by replicating data between databases. This helps ensure data remains accessible in case of hardware failures or planned maintenance.  

**Example (Conceptual - SQL Server):**  
Replication is often configured using SQL Server Management Studio and system stored procedures. For example, to set up snapshot replication, you might use:  
```sql
-- This is a conceptual example; actual replication setup involves several steps.
EXEC sp_addpublication 
    @publication = 'MySnapshotPublication', 
    @publication_type = 'snapshot',
    @description = 'Snapshot replication for high availability';
```
*Note: The full setup requires configuring publishers, distributors, and subscribers.*

---

## 32. Query Store and Plan Forcing  
**Purpose:**  
Capture historical query performance data to analyze and optimize queries. The Query Store also allows you to force a specific query plan if needed, helping mitigate performance regressions.  

**Example (SQL Server):**  
```sql
-- Enable Query Store on your database
ALTER DATABASE YourDatabase SET QUERY_STORE = ON;
```
After enabling, you can review performance data in SQL Server Management Studio and, if necessary, force an optimal plan using query hints (e.g., `OPTION (USE PLAN N'...')`).

---

## 33. Dynamic Data Masking  
**Purpose:**  
Protect sensitive information by masking it in query results without altering the underlying data. This is particularly useful for limiting exposure in non-privileged environments.  

**Example (SQL Server):**  
```sql
ALTER TABLE Customers
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
```
*This masks the email addresses so that only a partial view is returned to users without proper privileges.*

---

## 34. Distributed Transactions and Two-Phase Commit  
**Purpose:**  
Ensure atomic operations across multiple databases or servers. Distributed transactions coordinate commits across systems so that either all operations succeed or none do.  

**Example:**  
```sql
BEGIN DISTRIBUTED TRANSACTION;
  -- Execute operations across different databases/servers
  UPDATE DatabaseA.dbo.Orders SET Status = 'Processed' WHERE OrderID = 123;
  UPDATE DatabaseB.dbo.Inventory SET Quantity = Quantity - 1 WHERE ProductID = 456;
COMMIT TRANSACTION;
```
*Note: Distributed transactions require proper configuration of a transaction coordinator (e.g., MSDTC in SQL Server).*

---

## 35. Advanced Concurrency Control  
**Purpose:**  
Manage simultaneous data access using fine-tuned locking and isolation levels, reducing conflicts and improving performance in multi-user environments.  

**Example (SQL Server using SNAPSHOT isolation):**  
```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
  -- Perform concurrent-safe operations here
  UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID = 1;
  UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID = 2;
COMMIT TRANSACTION;
```
*Using SNAPSHOT isolation minimizes locking contention by providing a transactionally consistent view of the data.*

---

Below are additional advanced SQL features (items 36–40) that further extend your capabilities for handling complex, scalable, and high-performance database scenarios:

---

## 36. Database Sharding  
**Purpose:**  
Distribute large datasets across multiple database servers (shards) to enable horizontal scaling and improve performance under heavy loads.

**Concept:**  
Sharding is typically managed by the application or middleware rather than pure SQL. The idea is to partition data based on a key (like customer ID) so that each shard holds a subset of data.

**Conceptual Example:**  
```sql
-- Data distribution is managed externally. For example:
-- Orders for Customer IDs 1-10000 go to Shard1, 10001-20000 to Shard2, etc.
INSERT INTO Orders_Shard_1 (order_id, customer_id, order_date, amount) VALUES (...);
```

---

## 37. Read Replicas  
**Purpose:**  
Improve read performance and reduce load on the primary database by offloading read operations to one or more replica databases.

**Concept:**  
Read replicas are typically configured in managed or cloud environments. Applications can direct SELECT queries to a replica endpoint while write operations continue to use the primary database.

**Conceptual Note:**  
No specific SQL command is used here; rather, it’s about configuring your connection strings and database settings to point to a replica.

---

## 38. User-Defined Aggregate Functions (UDAFs)  
**Purpose:**  
Create custom aggregate functions to perform specialized summarizations that built-in functions might not cover.

**Example (Conceptual - PostgreSQL):**  
```sql
-- In PostgreSQL, you can define a custom aggregate function.
-- This example assumes you have created a supporting state function 'numeric_avg' to calculate the average.
CREATE AGGREGATE custom_avg(numeric) (
  sfunc = numeric_avg,  -- state function to process each value
  stype = numeric,      -- state data type
  initcond = '0'
);
```

*Note: Syntax and capabilities vary by database. SQL Server, for example, supports UDAFs via CLR integration.*

---

## 39. Column-Level Encryption  
**Purpose:**  
Enhance data security by encrypting sensitive data stored in specific columns. This protects data at rest and limits exposure if unauthorized access occurs.

**Example (SQL Server using symmetric key encryption):**  
```sql
-- First, open the symmetric key (configured previously with a certificate)
OPEN SYMMETRIC KEY MyKey DECRYPTION BY CERTIFICATE MyCert;

-- Encrypt the SSN column for a specific customer
UPDATE Customers 
SET EncryptedSSN = ENCRYPTBYKEY(KEY_GUID('MyKey'), SSN)
WHERE CustomerID = 123;
```

*This example encrypts the `SSN` field into a new column `EncryptedSSN`. Decryption would use the corresponding DECRYPTBYKEY function.*

---

## 40. Approximate Query Processing  
**Purpose:**  
Quickly run aggregations over massive datasets by returning approximate results with a known error margin. This is useful when speed is more critical than exact precision.

**Example (SQL Server / BigQuery):**  
```sql
SELECT APPROX_COUNT_DISTINCT(UserID) AS ApproxUserCount
FROM Logins;
```

*This query calculates an approximate distinct count of users, often much faster than an exact count on very large tables.*

---

These advanced features further empower you to build scalable, secure, and high-performance database solutions. Happy querying!
