## 24. External Tables / PolyBase
**Purpose:** Query data stored in external sources (like Hadoop, Azure Blob Storage, or flat files) as if it were in your local database.

**Example (SQL Server with PolyBase):**
```sql
CREATE EXTERNAL TABLE ExternalSales (
    SaleID INT,
    Amount DECIMAL(10,2)
)
WITH (
    LOCATION = 'externaldata/sales/',
    DATA_SOURCE = MyExternalDataSource,
    FILE_FORMAT = MyFileFormat
);
```