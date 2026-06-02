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

### **Pro Tips**  
- Always use `GROUP BY` with the formatted date (e.g., `DATE_FORMAT`) for time-based aggregation.  
- For performance, avoid functions on indexed date columns (e.g., `WHERE DATE(column) = ...`). Instead, use:  
  ```sql
  WHERE column BETWEEN '2023-10-01' AND '2023-10-01 23:59:59'
  ```  
