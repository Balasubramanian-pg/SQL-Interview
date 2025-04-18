
### **1. Core Date Functions**
- **`CURRENT_DATE`**  
  Returns current date (without time).  
  *MySQL: `CURDATE()`, SQL Server: `GETDATE()`*

- **`CURRENT_TIME`**  
  Returns current time (without date).  
  *MySQL: `CURTIME()`*

- **`CURRENT_TIMESTAMP`**  
  Returns current date and time.  
  *MySQL: `NOW()`, SQL Server: `GETDATE()`*

- **`EXTRACT(field FROM date)`**  
  Extracts a component (e.g., `YEAR`, `MONTH`, `DAY`, `HOUR`, `MINUTE`).  
  ```sql
  SELECT EXTRACT(MONTH FROM '2023-10-05') -- Returns 10
  ```

---

### **2. Date Formatting**
- **`TO_CHAR(date, format)`** (PostgreSQL)  
  Converts dates to strings.  
  *MySQL: `DATE_FORMAT(date, '%Y-%m-%d')`, SQL Server: `CONVERT(VARCHAR, date, 112)`*  
  ```sql
  SELECT TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS') -- 2023-10-05 14:30:00
  ```

- **`STR_TO_DATE(string, format)`** (MySQL)  
  Converts strings to dates.  
  *PostgreSQL: `TO_DATE()`*  
  ```sql
  SELECT STR_TO_DATE('05-10-2023', '%d-%m-%Y') -- 2023-10-05
  ```

---

### **3. Date Arithmetic**
- **`DATE_ADD(date, INTERVAL n unit)`** (MySQL)  
  Adds time intervals.  
  *SQL Server: `DATEADD(unit, n, date)`*  
  ```sql
  SELECT DATE_ADD(NOW(), INTERVAL 1 MONTH) -- Adds 1 month
  ```

- **`DATEDIFF(unit, start, end)`**  
  Calculates differences.  
  *MySQL: `DATEDIFF(end, start)` (days only), SQL Server: `DATEDIFF(day/hour, start, end)`*  
  ```sql
  SELECT DATEDIFF('2023-10-10', '2023-10-05') -- 5 days (MySQL)
  ```

---

### **4. Tricky Concepts**
- **Time Zones**  
  - Use `CONVERT_TZ(date, 'UTC', 'America/New_York')` (MySQL) or `AT TIME ZONE` (PostgreSQL/SQL Server).  
  - Storing dates in UTC is recommended.

- **Implicit Date Parsing**  
  - `WHERE date_column = '2023-10-05'` may fail due to time components; use:  
    ```sql
    WHERE date_column >= '2023-10-05' AND date_column < '2023-10-06'
    ```

- **Leap Years/End-of-Month**  
  - Adding 1 month to `2023-01-31` gives `2023-02-28` (not 31).  
  - Use `LAST_DAY(date)` (MySQL) to get month-end.

- **Week Start Days**  
  - Weeks start on Sunday (default in U.S.) vs. Monday (Europe). Use `SET DATEFIRST` (SQL Server) or `WEEKDAY` (MySQL).

---

### **5. Common Scenarios**
1. **Age Calculation**  
   ```sql
   SELECT EXTRACT(YEAR FROM AGE('2000-05-15')) -- PostgreSQL
   SELECT DATEDIFF(YEAR, '2000-05-15', GETDATE()) -- SQL Server
   ```

2. **First Day of Month**  
   ```sql
   SELECT DATE_TRUNC('month', CURRENT_DATE) -- PostgreSQL
   SELECT DATEADD(DAY, 1 - DAY(GETDATE()), GETDATE()) -- SQL Server
   ```

3. **Group by Week**  
   ```sql
   SELECT DATE_TRUNC('week', date_column), COUNT(*) 
   FROM table GROUP BY 1 -- PostgreSQL
   ```

4. **Business Days (Exclude Weekends)**  
   ```sql
   SELECT COUNT(*) 
   FROM dates
   WHERE DAYOFWEEK(date) NOT IN (1, 7) -- 1=Sunday (MySQL)
   ```

---

### **6. Dialect-Specific Notes**
- **MySQL**: Uses `%` specifiers in `DATE_FORMAT` (e.g., `%Y` for year).  
- **PostgreSQL**: Prefers `DATE_TRUNC` and `INTERVAL '1 day'`.  
- **SQL Server**: Uses `DATEPART`, `DATEADD`, and `DATEDIFF` with different syntax.

---

**Key Interview Traps**  
- Mixing `DATE` and `TIMESTAMP` types.  
- Assuming `DATEDIFF` counts 24-hour periods (it counts crossed boundaries).  
- Time zone ignorance in distributed systems.  
- Month/year rounding edge cases (e.g., `2023-01-31 + 1 MONTH`).

Here's an expanded cheat sheet covering date ranges, period comparisons, and trend analysis functions (with dialect variations):

---

### **1. First/Last Date in Period**
- **First Day of Month**  
  ```sql
  -- PostgreSQL
  SELECT DATE_TRUNC('month', CURRENT_DATE)::DATE
  
  -- MySQL
  SELECT DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
  
  -- SQL Server
  SELECT DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  ```

- **Last Day of Month**  
  ```sql
  -- PostgreSQL
  (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE
  
  -- MySQL
  SELECT LAST_DAY(CURRENT_DATE)
  
  -- SQL Server
  SELECT EOMONTH(GETDATE())
  ```

---

### **2. Date Ranges**
- **Check if Date is Between Two Dates**  
  ```sql
  SELECT *
  FROM orders
  WHERE order_date BETWEEN '2023-10-01' AND '2023-10-31'
  -- Note: Use CAST() if time components exist
  ```

- **Generate Date Range**  
  ```sql
  -- PostgreSQL (generate_series)
  SELECT generate_series('2023-10-01'::DATE, '2023-10-31'::DATE, '1 day')::DATE AS date
  
  -- SQL Server (recursive CTE)
  WITH dates AS (
    SELECT CAST('2023-10-01' AS DATE) AS date
    UNION ALL
    SELECT DATEADD(day, 1, date)
    FROM dates
    WHERE date < '2023-10-31'
  )
  SELECT * FROM dates
  ```

---

### **3. Days Between Dates**
- **Exact Day Difference**  
  ```sql
  -- Standard
  SELECT DATE_DIFF('day', start_date, end_date)
  
  -- MySQL
  SELECT DATEDIFF(end_date, start_date)
  
  -- SQL Server
  SELECT DATEDIFF(day, start_date, end_date)
  ```

---

### **4. Same Period Comparisons**
- **Same Month Last Year**  
  ```sql
  -- PostgreSQL
  SELECT DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 year'
  
  -- SQL Server
  SELECT DATEADD(year, -1, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
  ```

- **Same Week Last Year**  
  ```sql
  -- PostgreSQL
  SELECT DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1 year'
  
  -- MySQL (adjust week mode if needed)
  SELECT DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR) - INTERVAL (DAYOFWEEK(CURRENT_DATE)-1) DAY
  ```

---

### **5. Trend Analysis**
- **Month-over-Month Growth**  
  ```sql
  WITH monthly_sales AS (
    SELECT 
      DATE_TRUNC('month', order_date) AS month,
      SUM(sales) AS total_sales
    FROM orders
    GROUP BY 1
  )
  SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
    (total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month) AS mom_growth
  FROM monthly_sales
  ```

- **Year-over-Year Comparison**  
  ```sql
  SELECT
    DATE_TRUNC('month', order_date) AS current_month,
    SUM(sales) AS current_sales,
    LAG(SUM(sales), 12) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS prev_year_sales
  FROM orders
  GROUP BY 1
  ```

---

### **6. Advanced Interval Logic**
- **Working Days Between Dates (Exclude Weekends)**  
  ```sql
  -- PostgreSQL
  SELECT COUNT(*) FILTER (WHERE EXTRACT(ISODOW FROM date) < 6)
  FROM generate_series('2023-10-01', '2023-10-31', '1 day') AS date
  ```

- **Next Business Day (Skip Weekends)**  
  ```sql
  -- MySQL
  SELECT 
    CASE 
      WHEN DAYOFWEEK(CURRENT_DATE + INTERVAL 1 DAY) = 1 THEN CURRENT_DATE + INTERVAL 2 DAY
      WHEN DAYOFWEEK(CURRENT_DATE + INTERVAL 1 DAY) = 7 THEN CURRENT_DATE + INTERVAL 3 DAY
      ELSE CURRENT_DATE + INTERVAL 1 DAY
    END AS next_biz_day
  ```

---

### **7. Tricky Scenarios**
1. **Leap Year Handling**  
   `DATE '2020-02-29' + INTERVAL '1 year'` → Returns `2021-02-28` in most systems.

2. **Month Addition Edge Cases**  
   ```sql
   SELECT DATE_ADD('2023-01-31', INTERVAL 1 MONTH) → 2023-02-28
   ```

3. **Week Boundaries**  
   Use `ISOWEEK` (PostgreSQL) or adjust `DATEFIRST` (SQL Server) for consistent weekly grouping.

4. **Fiscal Year Calculations**  
   ```sql
   -- Shift dates by 3 months for fiscal year starting April
   SELECT DATE_TRUNC('month', order_date + INTERVAL '3 months') AS fiscal_month
   ```

---

### **8. Common Interview Questions**
- "How would you calculate running 7-day averages?"
- "Handle time zones in a global sales report?"
- "Calculate age in years/months/days accurately?"
- "Find overlapping date ranges between two bookings?"
- "How to optimize date range queries in large tables?"

---

**Key Patterns**  
- Always use **DATE_TRUNC** or equivalent for period grouping  
- Prefer **EXTRACT** for component isolation  
- Use **LAG/LEAD** for period comparisons  
- **BETWEEN** is inclusive; use `< next_period_start` for safety  
- Always test edge cases: month-ends, leap years, time zones



Here are **20 additional tricky SQL date function concepts** not previously covered, focusing on edge cases, lesser-known behaviors, and dialect-specific quirks:

---

### **1. Daylight Saving Time (DST) Transitions**
- Adding `INTERVAL '1 day'` across a DST boundary may result in a 23- or 25-hour day. Use `AT TIME ZONE` to handle clock changes explicitly.
- Example (PostgreSQL):
  ```sql
  SELECT TIMESTAMP '2023-03-12 02:30:00 America/New_York' + INTERVAL '1 day'
  -- Returns 2023-03-13 03:30:00 (due to DST start).
  ```

---

### **2. Epoch Time Conversion**
- Epoch time (Unix time) conversion varies:
  - PostgreSQL: `TO_TIMESTAMP(epoch)`
  - MySQL: `FROM_UNIXTIME(epoch)`
  - SQL Server: `DATEADD(second, epoch, '1970-01-01')`

---

### **3. Fractional Seconds Precision**
- Truncating timestamps to milliseconds vs. microseconds can cause equality checks to fail:
  ```sql
  -- PostgreSQL
  SELECT '2023-10-05 12:00:00.123456'::TIMESTAMP = '2023-10-05 12:00:00.123'::TIMESTAMP -- False
  ```

---

### **4. NULL Dates in Arithmetic**
- `NULL + INTERVAL '1 day'` returns `NULL`, which can break date series. Use `COALESCE`:
  ```sql
  SELECT COALESCE(end_date, CURRENT_DATE) + INTERVAL 1 DAY
  ```

---

### **5. Calendar System Limitations**
- SQL engines use Gregorian calendars by default. Hijri, Julian, or other calendars require manual conversion or extensions (e.g., PostgreSQL’s `calendar` extension).

---

### **6. Date Overflow Errors**
- Using `SMALLDATETIME` in SQL Server (range 1900-01-01 to 2079-06-06) with out-of-range dates throws errors:
  ```sql
  SELECT CAST('2079-06-07' AS SMALLDATETIME) -- Fails
  ```

---

### **7. Week Number Inconsistencies**
- `WEEK()` in MySQL has modes (0-7), affecting week 1 definitions. For ISO weeks, use `WEEK(date, 3)`.

---

### **8. Implicit String-to-Date Casting**
- `WHERE date_column = '05/10/2023'` may interpret as MM/DD or DD/MM based on server locale. Always use `YYYY-MM-DD`.

---

### **9. Quarter Boundary Ambiguity**
- Fiscal quarters vs. calendar quarters:
  ```sql
  -- Fiscal Q1 starting in April (PostgreSQL):
  SELECT EXTRACT(QUARTER FROM date_column + INTERVAL '3 months') AS fiscal_quarter
  ```

---

### **10. Timezone Offsets as Numbers**
- Storing time zones as numeric offsets (e.g., `+02:00`) instead of named zones (e.g., `Europe/Paris`) fails to account for DST changes.

---

### **11. Leap Seconds**
- Most SQL systems ignore leap seconds. `2023-12-31 23:59:60` is invalid in standard SQL.

---

### **12. Custom Intervals (e.g., N Workdays)**
- Skipping weekends/holidays requires recursive logic:
  ```sql
  -- PostgreSQL (5 workdays ahead):
  WITH RECURSIVE dates AS (
    SELECT CURRENT_DATE AS date, 0 AS days
    UNION ALL
    SELECT date + INTERVAL '1 day', days + 1
    FROM dates
    WHERE days < 5 AND EXTRACT(ISODOW FROM date + INTERVAL '1 day') < 6
  )
  SELECT MAX(date) FROM dates;
  ```

---

### **13. Localized Month/Weekday Names**
- `DATENAME` in SQL Server returns localized names based on server settings:
  ```sql
  SET LANGUAGE French;
  SELECT DATENAME(month, '2023-10-05') -- Returns 'octobre'
  ```

---

### **14. Infinite Dates**
- PostgreSQL supports `-infinity` and `infinity` for dates. Comparisons like `date > 'infinity'` return false.

---

### **15. Microsecond Truncation**
- Truncating timestamps to seconds discards microseconds, impacting uniqueness:
  ```sql
  INSERT INTO logs (timestamp) VALUES ('2023-10-05 12:00:00.123456'), ('2023-10-05 12:00:00.123');
  -- May violate unique constraints if truncated.
  ```

---

### **16. Timezone-Aware Aggregation**
- Grouping by `DATE(timestamp AT TIME ZONE 'UTC')` for global data avoids timezone skew.

---

### **17. Date Validation in Constraints**
- Use `CHECK` constraints to block invalid dates:
  ```sql
  CREATE TABLE events (
    event_date DATE CHECK (event_date BETWEEN '2000-01-01' AND '2100-01-01')
  );
  ```

---

### **18. Non-Contiguous Date Ranges**
- Gaps in time series (e.g., missing dates) require `GENERATE_SERIES` or calendar tables to detect.

---

### **19. Date Formatting Localization**
- `TO_CHAR(date, 'Month')` in PostgreSQL pads month names with spaces (e.g., 'October  '). Use `FM` to trim:
  ```sql
  SELECT TO_CHAR(NOW(), 'FMMonth'); -- 'October'
  ```

---

### **20. Session vs. System Time**
- `CURRENT_TIMESTAMP` uses session time zones, while the system clock may differ. Override with:
  ```sql
  SET TIME ZONE 'UTC'; -- PostgreSQL
  ```

---

### **Key Takeaways**
1. **Test edge cases**: DST, leap years, month-ends, and time zones.
2. **Avoid implicit casting**: Use explicit `CAST`/`CONVERT`.
3. **Prefer named time zones** over numeric offsets.
4. **Use calendar tables** for complex business logic (holidays, fiscal years).
5. **Document assumptions** about week/month start days and localization.


Here are **20 essential SQL code snippets** (with dialect variations) that cover **80% of date-related interview scenarios**, focusing on real-world use cases and edge cases:

---

### **1. Calculate Age Accurately**
```sql
-- PostgreSQL
SELECT EXTRACT(YEAR FROM AGE('2000-02-29'::DATE)) -- Returns 23 in 2023

-- SQL Server
SELECT DATEDIFF(YEAR, '2000-02-29', GETDATE()) - 
  CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, '2000-02-29', GETDATE()), '2000-02-29') > GETDATE() 
  THEN 1 ELSE 0 END
```

---

### **2. Last Day of Current Month**
```sql
-- MySQL
SELECT LAST_DAY(CURDATE())

-- SQL Server
SELECT EOMONTH(GETDATE())

-- PostgreSQL
SELECT (DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH - 1 DAY')::DATE
```

---

### **3. First Monday of Month**
```sql
-- PostgreSQL
SELECT DATE_TRUNC('MONTH', CURRENT_DATE) + (7 - EXTRACT(DOW FROM DATE_TRUNC('MONTH', CURRENT_DATE)) + 1) % 7 * INTERVAL '1 DAY'

-- MySQL
SELECT ADDDATE(LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH), 
  INTERVAL (8 - DAYOFWEEK(LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH))) % 7 DAY)
```

---

### **4. Week Number (ISO Standard)**
```sql
-- PostgreSQL
SELECT EXTRACT(ISOYEAR FROM date_col) AS isoyear, EXTRACT(WEEK FROM date_col) AS isoweek

-- MySQL
SELECT YEARWEEK(date_col, 3) -- Mode 3 = ISO 8601
```

---

### **5. Business Days Between Dates (Exclude Weekends)**
```sql
-- PostgreSQL
SELECT COUNT(*) FILTER (WHERE EXTRACT(ISODOW FROM day) < 6)
FROM generate_series('2023-10-01', '2023-10-31', '1 DAY') AS day
```

---

### **6. Same Period Last Year (SPLY)**
```sql
-- For any date
SELECT 
  date_col,
  DATE_TRUNC('MONTH', date_col) - INTERVAL '1 YEAR' AS sply_month_start,
  DATE_TRUNC('WEEK', date_col) - INTERVAL '1 YEAR' AS sply_week_start
```

---

### **7. Last 30 Days (Including Today)**
```sql
SELECT *
FROM sales
WHERE sale_date BETWEEN CURRENT_DATE - INTERVAL '29 DAY' AND CURRENT_DATE
```

---

### **8. Extract Time from Timestamp**
```sql
-- PostgreSQL
SELECT date_col::TIME

-- MySQL
SELECT TIME(date_col)

-- SQL Server
SELECT CAST(date_col AS TIME)
```

---

### **9. Format Date for JSON/APIs**
```sql
-- Standard
SELECT TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')

-- SQL Server
SELECT FORMAT(GETDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ')
```

---

### **10. Calculate Running 7-Day Average**
```sql
SELECT
  date,
  AVG(sales) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
FROM daily_sales
```

---

### **11. Handle Time Zones in Queries**
```sql
-- MySQL
SELECT CONVERT_TZ(utc_timestamp, 'UTC', 'America/Los_Angeles')

-- PostgreSQL
SELECT utc_timestamp AT TIME ZONE 'America/Los_Angeles'
```

---

### **12. Generate Date Series with Gaps**
```sql
-- PostgreSQL
SELECT generate_series('2023-01-01', '2023-12-31', '1 DAY')::DATE AS date
LEFT JOIN sales USING (date)
```

---

### **13. Month-over-Month Growth**
```sql
WITH monthly AS (
  SELECT 
    DATE_TRUNC('MONTH', date) AS month,
    SUM(revenue) AS rev
  FROM sales
  GROUP BY 1
)
SELECT 
  month,
  rev,
  (rev - LAG(rev) OVER (ORDER BY month)) / LAG(rev) OVER (ORDER BY month) AS mom_growth
FROM monthly
```

---

### **14. Fiscal Year Calculation**
```sql
-- Fiscal year starting April (adjust offset)
SELECT 
  CASE 
    WHEN EXTRACT(MONTH FROM date) >= 4 THEN EXTRACT(YEAR FROM date)
    ELSE EXTRACT(YEAR FROM date) - 1 
  END AS fiscal_year
```

---

### **15. Find Overlapping Date Ranges**
```sql
SELECT *
FROM bookings a
JOIN bookings b 
  ON a.start_date < b.end_date 
  AND a.end_date > b.start_date 
  AND a.id != b.id
```

---

### **16. Add Workdays to Date**
```sql
-- PostgreSQL (Recursive CTE)
WITH RECURSIVE workdays AS (
  SELECT CURRENT_DATE AS day, 5 AS days_left
  UNION ALL
  SELECT 
    day + INTERVAL '1 DAY',
    days_left - CASE WHEN EXTRACT(ISODOW FROM day + INTERVAL '1 DAY') < 6 THEN 1 ELSE 0 END
  FROM workdays
  WHERE days_left > 0
)
SELECT MAX(day) FROM workdays
```

---

### **17. Convert Epoch to Timestamp**
```sql
-- PostgreSQL
SELECT TO_TIMESTAMP(1696500000)

-- MySQL
SELECT FROM_UNIXTIME(1696500000)
```

---

### **18. Calculate SLA Breach Time**
```sql
-- Exclude weekends and 9 AM-5 PM working hours
SELECT 
  created_at,
  created_at + INTERVAL '4 HOURS' * 
    (1 + FLOOR((EXTRACT(EPOCH FROM (resolved_at - created_at)) / (8*3600))) AS sla_breach_time
FROM tickets
```

---

### **19. Last 12 Months Rolling**
```sql
SELECT *
FROM sales
WHERE date >= DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '11 MONTH')
```

---

### **20. Handle Leap Year in Date Math**
```sql
-- Safe year addition
SELECT 
  CASE 
    WHEN EXTRACT(DAY FROM date_col + INTERVAL '1 YEAR') != EXTRACT(DAY FROM date_col)
    THEN date_col + INTERVAL '1 YEAR' - INTERVAL '1 DAY'
    ELSE date_col + INTERVAL '1 YEAR'
  END
```

---

### **Key Takeaways**
1. **Window functions** (`LAG`, `LEAD`, `OVER`) are essential for trend analysis.
2. Always use **DATE_TRUNC** for period grouping.
3. **Recursive CTEs** solve workday/interval problems.
4. **Generate_series/Recursive CTEs** handle date gaps.
5. **Time zone functions** prevent silent data corruption.
6. **Test edge cases**: month-ends, leap years, DST changes.

These snippets cover date arithmetic, reporting periods, time zones, and edge cases that dominate 80% of real-world scenarios.
