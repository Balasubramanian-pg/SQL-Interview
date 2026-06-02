## 36. Database Sharding  
**Purpose:**  
Distribute large datasets across multiple database servers (shards) to enable horizontal scaling and improve performance under heavy loads.

**Concept:**  
Sharding is typically managed by the application or middleware rather than pure SQL. The idea is to partition data based on a key (like customer ID) so that each shard holds a subset of data.

**Conceptual Example:**  
```sql
-- Data distribution is managed externally. For example:
-- Orders for Customer IDs 1-10000 go to Shard1, 10001-20000 to Shard2, etc.
INSERT INTO Orders_Shard_1 (order_id, customer_id, order_date, amount) VALUES (...);
```