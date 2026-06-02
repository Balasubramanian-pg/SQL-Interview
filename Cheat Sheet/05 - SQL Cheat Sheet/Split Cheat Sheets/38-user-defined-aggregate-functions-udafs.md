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