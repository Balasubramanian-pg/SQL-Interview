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
