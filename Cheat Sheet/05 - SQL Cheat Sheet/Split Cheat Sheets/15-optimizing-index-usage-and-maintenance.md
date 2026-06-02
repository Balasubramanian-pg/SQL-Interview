## 15. Optimizing Index Usage and Maintenance  
**Purpose:** Enhance query performance by creating, analyzing, and maintaining indexes.

- **Creating a Composite Index:**
  ```sql
  CREATE INDEX idx_customer_order ON orders(customer_id, order_date);
  ```
  *A composite index can speed up queries filtering on both `customer_id` and `order_date`.*

- **Rebuilding an Index (SQL Server):**
  ```sql
  ALTER INDEX idx_customer_order ON orders REBUILD;
  ```
  *Regular index maintenance (like rebuilding) ensures optimal performance.*