## 23. Graph Queries
**Purpose:** Model and query complex many-to-many relationships (such as social networks or recommendation systems) using node and edge tables.

**Example (SQL Server):**
```sql
-- Create node table for persons
CREATE TABLE Person (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
) AS NODE;

-- Create edge table for friendships
CREATE TABLE Friendship (
    $from_id INT,
    $to_id INT
) AS EDGE;

-- Query to find a person's friends:
SELECT p.Name, f.$to_id
FROM Person p
JOIN Friendship f ON p.ID = f.$from_id;
```