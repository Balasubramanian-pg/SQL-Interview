### MySQL Date Functions Cheat Sheet for Interviews

#### 1. **Current Date/Time**
- **`CURDATE()`**: Current date (e.g., `'2023-10-25'`).
  ```sql
  SELECT CURDATE(); -- 2023-10-25
  ```
- **`NOW()`**: Current datetime (e.g., `'2023-10-25 12:34:56'`).
  ```sql
  SELECT NOW(); -- 2023-10-25 12:34:56
  ```

#### 2. **Extract Date Parts**
- **`YEAR(date)`**, **`MONTH(date)`**, **`DAY(date)`**:
  ```sql
  SELECT YEAR('2023-10-25') AS yr; -- 2023
  ```
- **`EXTRACT(unit FROM date)`**:
  ```sql
  SELECT EXTRACT(WEEK FROM '2023-10-25') AS week; -- 43
  ```

#### 3. **Date Arithmetic**
- **`DATEDIFF(date1, date2)`**: Days between `date1` and `date2`.
  ```sql
  SELECT DATEDIFF('2023-10-25', '2023-10-20'); -- 5
  ```
- **`DATE_ADD(date, INTERVAL n unit)`** / **`DATE_SUB`**:
  ```sql
  SELECT DATE_ADD('2023-10-25', INTERVAL 7 DAY); -- 2023-11-01
  ```
- **`TIMESTAMPDIFF(unit, start, end)`**:
  ```sql
  SELECT TIMESTAMPDIFF(YEAR, '2000-10-25', CURDATE()); -- Age in years
  ```

#### 4. **Formatting & Conversion**
- **`DATE_FORMAT(date, format)`**:
  ```sql
  SELECT DATE_FORMAT(NOW(), '%Y-%m'); -- '2023-10'
  ```
- **`STR_TO_DATE(str, format)`**:
  ```sql
  SELECT STR_TO_DATE('25-10-2023', '%d-%m-%Y'); -- 2023-10-25
  ```

#### 5. **Date Components**
- **`DAYNAME(date)`**: Weekday name (e.g., `'Wednesday'`).
- **`LAST_DAY(date)`**: Last day of the month.
  ```sql
  SELECT LAST_DAY('2023-02-15'); -- 2023-02-28
  ```

---

### Common Interview Questions & Solutions

#### Q1: Find users active for 3+ consecutive days.
**Approach**: Use self-join or window functions (`LAG/LEAD`) with `DATEDIFF`.
```sql
SELECT DISTINCT a.user_id
FROM Logs a
JOIN Logs b ON a.user_id = b.user_id 
  AND DATEDIFF(a.login_date, b.login_date) = 1
JOIN Logs c ON a.user_id = c.user_id 
  AND DATEDIFF(b.login_date, c.login_date) = 1;
```

#### Q2: Calculate monthly active users (MAU).
**Solution**: Group by year-month.
```sql
SELECT DATE_FORMAT(login_date, '%Y-%m') AS month, COUNT(DISTINCT user_id) AS MAU
FROM Logs
GROUP BY month;
```

#### Q3: Find orders placed yesterday.
```sql
SELECT *
FROM Orders
WHERE DATE(order_date) = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
```

#### Q4: Get the last day of the current month.
```sql
SELECT LAST_DAY(CURDATE());
```

#### Q5: Calculate age from birthdate.
```sql
SELECT TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age FROM Users;
```

#### Q6: Find weekdays with the highest sales.
```sql
SELECT DAYNAME(order_date) AS day, COUNT(*) AS sales
FROM Orders
GROUP BY day
ORDER BY sales DESC LIMIT 1;
```

---

### Key Patterns to Remember:
- **Consecutive Days**: Use `DATEDIFF` with offsets (e.g., `DATEDIFF(a.date, b.date) = 1`).
- **Time-Based Filtering**: `BETWEEN`, `DATE_SUB`, or `INTERVAL`.
- **Group by Time Units**: `DATE_FORMAT` for custom grouping (e.g., `%Y-%W` for week).
- **Date Validation**: Check `LAST_DAY` for month-end edge cases.

📌 **Pro Tip**: Always handle `NULL` dates with `COALESCE` and validate date ranges (e.g., `BETWEEN` vs `>= AND <`).



Here’s a breakdown of **top LeetCode-style questions** where date functions are critical, with solutions and explanations of how MySQL date functions are applied:

---

### **1. Consecutive Logins (LeetCode 550: Game Play Analysis IV)**
**Problem**: Find the fraction of players who logged in again the day after their first login.  
**Key Date Functions**: `DATEDIFF`, `MIN`, `DATE_ADD`  
**Solution**:
```sql
SELECT ROUND(
    COUNT(DISTINCT CASE WHEN DATEDIFF(a.event_date, first_login) = 1 THEN a.player_id END) 
    / COUNT(DISTINCT a.player_id), 2
) AS fraction
FROM Activity a
JOIN (
    SELECT player_id, MIN(event_date) AS first_login
    FROM Activity
    GROUP BY player_id
) t 
ON a.player_id = t.player_id;
```
**Breakdown**:  
- `MIN(event_date)` finds the first login date.  
- `DATEDIFF` checks if subsequent logins are exactly 1 day after the first login.  

---

### **2. Active Users (LeetCode 1454: Active Users)**
**Problem**: Find users active for 5+ consecutive days.  
**Key Date Functions**: `DATE_SUB`, `ROW_NUMBER`, `GROUP_CONCAT`  
**Solution**:
```sql
WITH temp AS (
    SELECT 
        id, login_date,
        DATE_SUB(login_date, INTERVAL ROW_NUMBER() OVER (PARTITION BY id ORDER BY login_date) DAY) AS grp
    FROM Logins
    GROUP BY id, login_date
)
SELECT DISTINCT id
FROM temp
GROUP BY id, grp
HAVING COUNT(*) >= 5;
```
**Breakdown**:  
- `DATE_SUB` subtracts a row number (as days) to create a grouping identifier (`grp`).  
- Consecutive dates will have the same `grp`, so grouping by `grp` counts consecutive streaks.

---

### **3. Monthly Transactions (LeetCode 1193: Monthly Transactions I)**
**Problem**: Report monthly transactions count and total amount.  
**Key Date Functions**: `DATE_FORMAT`  
**Solution**:
```sql
SELECT 
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(*) AS trans_count,
    SUM(amount) AS trans_total_amount
FROM Transactions
GROUP BY month, country;
```
**Breakdown**:  
- `DATE_FORMAT(trans_date, '%Y-%m')` groups transactions by year-month (e.g., `2023-10`).

---

### **4. Restaurant Growth (LeetCode 1321: Restaurant Growth)**
**Problem**: Compute moving average revenue over a 7-day window.  
**Key Date Functions**: `RANGE INTERVAL`, `BETWEEN`  
**Solution**:
```sql
SELECT 
    visited_on,
    SUM(amount) OVER (ORDER BY visited_on RANGE BETWEEN INTERVAL 6 DAY PRECEDING AND CURRENT ROW) AS amount,
    ROUND(AVG(amount) OVER (ORDER BY visited_on RANGE BETWEEN INTERVAL 6 DAY PRECEDING AND CURRENT ROW), 2) AS average_amount
FROM (
    SELECT visited_on, SUM(amount) AS amount
    FROM Customer
    GROUP BY visited_on
) t;
```
**Breakdown**:  
- `RANGE BETWEEN INTERVAL 6 DAY PRECEDING` creates a 7-day window (current day + 6 preceding days).

---

### **5. Human Traffic of Stadium (LeetCode 601)**
**Problem**: Find dates with > 100 people for 3+ consecutive days.  
**Key Date Functions**: `DATEDIFF`, `ROW_NUMBER`  
**Solution**:
```sql
WITH temp AS (
    SELECT 
        id, visit_date, people,
        id - ROW_NUMBER() OVER (ORDER BY visit_date) AS grp
    FROM Stadium
    WHERE people >= 100
)
SELECT id, visit_date, people
FROM temp
WHERE grp IN (
    SELECT grp
    FROM temp
    GROUP BY grp
    HAVING COUNT(*) >= 3
);
```
**Breakdown**:  
- Uses `ROW_NUMBER()` and arithmetic to group consecutive days (similar to **Active Users** pattern).

---

### **6. Last Person to Fit in the Bus (LeetCode 1204)**
**Problem**: Find the last person to board a bus with a 1000 kg weight limit.  
**Key Date Functions**: `ORDER BY` (implicit date sorting)  
**Solution**:
```sql
SELECT person_name
FROM (
    SELECT 
        person_name,
        SUM(weight) OVER (ORDER BY turn) AS cumulative_weight
    FROM Queue
) t
WHERE cumulative_weight <= 1000
ORDER BY cumulative_weight DESC
LIMIT 1;
```
**Breakdown**:  
- Though not date-specific, this uses `ORDER BY` to process entries chronologically (based on `turn`).

---

### **7. Find Missing Dates (Custom Problem)**
**Problem**: Identify dates with no activity in a table.  
**Key Date Functions**: `GENERATE_SERIES` (simulated via recursive CTE)  
**Solution**:
```sql
WITH RECURSIVE dates AS (
    SELECT '2023-01-01' AS date
    UNION ALL
    SELECT DATE_ADD(date, INTERVAL 1 DAY)
    FROM dates
    WHERE date < '2023-01-31'
)
SELECT d.date
FROM dates d
LEFT JOIN Activity a ON d.date = a.event_date
WHERE a.event_date IS NULL;
```
**Breakdown**:  
- Recursive CTE generates all dates in a range.  
- `DATE_ADD` increments dates by 1 day.  

---

### **Key Date Functions & Patterns**  
1. **Consecutive Days**:  
   - Use `ROW_NUMBER()` with `DATE_SUB` to group streaks.  
   - Example: `DATE_SUB(date, INTERVAL ROW_NUMBER() DAY)`.  

2. **Time Windows**:  
   - `RANGE BETWEEN INTERVAL n DAY PRECEDING` for moving averages.  
   - `DATEDIFF(date1, date2) = 1` for day-after logic.  

3. **Date Formatting**:  
   - `DATE_FORMAT` for grouping by month/week/year.  

4. **Edge Cases**:  
   - Use `LAST_DAY(date)` for month-end calculations.  
   - Handle leap years with `YEAR(date)` and `MONTH(date)` checks.  

---

### **Pro Tips**  
- Always use `GROUP BY` with the formatted date (e.g., `DATE_FORMAT`) for time-based aggregation.  
- For performance, avoid functions on indexed date columns (e.g., `WHERE DATE(column) = ...`). Instead, use:  
  ```sql
  WHERE column BETWEEN '2023-10-01' AND '2023-10-01 23:59:59'
  ```  

This cheat sheet covers patterns for 80% of date-related interview questions. Practice these, and you’ll crush time-series SQL problems! 🚀
