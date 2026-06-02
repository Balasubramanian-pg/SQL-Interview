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
