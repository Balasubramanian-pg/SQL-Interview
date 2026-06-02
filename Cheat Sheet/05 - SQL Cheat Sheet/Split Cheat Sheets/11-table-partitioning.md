## 11. Table Partitioning  
**Purpose:** Divide large tables into smaller, more manageable pieces to improve performance and maintenance.

- **Example (MySQL Range Partitioning):**
  ```sql
  CREATE TABLE orders (
      order_id INT,
      order_date DATE,
      amount DECIMAL(10,2)
  )
  PARTITION BY RANGE (YEAR(order_date)) (
      PARTITION p2019 VALUES LESS THAN (2020),
      PARTITION p2020 VALUES LESS THAN (2021),
      PARTITION p2021 VALUES LESS THAN (2022)
  );
  ```
  *This partitions the `orders` table by year, making queries on specific date ranges more efficient.*