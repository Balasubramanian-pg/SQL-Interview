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
