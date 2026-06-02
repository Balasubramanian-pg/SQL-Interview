# QUERY 5	
## Ungroup the given input data

### PROBLEM STATEMENT	
Ungroup the given input data. Display the result as per expected output

![image](https://github.com/user-attachments/assets/b4afe78d-e3fe-4614-bdc4-ba35cbd8959c)

# SQL Query to Ungroup Data

## Problem Understanding
We need to transform the grouped data (with counts) into individual rows for each item. For example, "Water Bottle" with total_count=2 should become two separate rows of "Water Bottle".

## Solution

```sql
WITH numbers AS (
    SELECT generate_series(1, (SELECT MAX(total_count) FROM items)) AS n
)
SELECT 
    i.id,
    i.item_name,
    1 AS count_per_item
FROM 
    items i
JOIN 
    numbers n ON n.n <= i.total_count
ORDER BY 
    i.id, n.n;
```
