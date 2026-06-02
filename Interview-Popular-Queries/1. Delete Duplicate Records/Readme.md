QUERY 1	Delete duplicate data
PROBLEM STATEMENT	From the given CARS table, delete the records where car details are duplicated 
![image](https://github.com/user-attachments/assets/4a00aa05-1e79-4f35-97c9-61b45e567efc)

# 7 Solutions to Delete Duplicate Records from CARS Table

## Understanding the Problem
The table contains duplicate records where multiple rows have identical `model_name`, `color`, and `brand` values (e.g., Leaf Black Nissan appears twice, Ioniq 5 Black Hyundai appears twice).

Here are 7 different solutions to delete these duplicates:

### Solution 1: Using GROUP BY with MIN/MAX model_id
```sql
DELETE FROM cars
WHERE model_id NOT IN (
    SELECT MIN(model_id)
    FROM cars
    GROUP BY model_name, color, brand
);
```

