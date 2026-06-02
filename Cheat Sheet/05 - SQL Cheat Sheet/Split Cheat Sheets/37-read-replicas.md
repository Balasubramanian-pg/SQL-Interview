## 37. Read Replicas  
**Purpose:**  
Improve read performance and reduce load on the primary database by offloading read operations to one or more replica databases.

**Concept:**  
Read replicas are typically configured in managed or cloud environments. Applications can direct SELECT queries to a replica endpoint while write operations continue to use the primary database.

**Conceptual Note:**  
No specific SQL command is used here; rather, it’s about configuring your connection strings and database settings to point to a replica.