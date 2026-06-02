## 19. Advanced Data Types  
**Purpose:** Leverage specialized types for complex data such as XML, arrays, or geospatial data.

- **XML:**  
  **Example (SQL Server):**
  ```sql
  DECLARE @xml XML = '<root><item id="1">Value</item></root>';
  SELECT @xml.value('(/root/item/@id)[1]', 'INT') AS ItemID;
  ```
  
- **Arrays (PostgreSQL):**  
  **Example:**
  ```sql
  SELECT ARRAY[1, 2, 3] AS numbers;
  ```

*Using these types can simplify the storage and querying of structured data.*