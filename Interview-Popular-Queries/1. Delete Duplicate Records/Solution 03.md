
### Solution 3: Using a temporary table
```sql
CREATE TABLE cars_temp AS
SELECT MIN(model_id) AS model_id, model_name, color, brand
FROM cars
GROUP BY model_name, color, brand;

TRUNCATE TABLE cars;

INSERT INTO cars
SELECT * FROM cars_temp;

DROP TABLE cars_temp;
```
