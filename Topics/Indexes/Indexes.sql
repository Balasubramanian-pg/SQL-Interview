```sql
/*
================================================================================
COMPREHENSIVE SQL INDEXES TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to SQL Indexes with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- Indexes = Database objects that improve query performance
-- Focus: Types, creation, management, optimization, and monitoring
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'IndexesTutorialDB')
BEGIN
    ALTER DATABASE IndexesTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IndexesTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE IndexesTutorialDB;
GO

USE IndexesTutorialDB;
GO

-- Configure database for index demonstrations
ALTER DATABASE IndexesTutorialDB SET RECOVERY SIMPLE;  -- For log management
GO

-- Enable advanced options
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create comprehensive sample schema for index demonstrations
-- Large tables for performance testing
--------------------------------------------------------------------

-- Create Customers table (will be populated with 100,000+ rows)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode AS ('CUST' + RIGHT('000000' + CAST(CustomerID AS VARCHAR(6)), 6)) PERSISTED,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    AddressLine1 NVARCHAR(100),
    AddressLine2 NVARCHAR(100),
    City NVARCHAR(50) NOT NULL,
    State CHAR(2),
    PostalCode VARCHAR(20),
    Country NVARCHAR(50) DEFAULT 'USA',
    DateOfBirth DATE,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL,
    TotalOrders INT DEFAULT 0,
    TotalSpent DECIMAL(15,2) DEFAULT 0.00,
    CustomerType VARCHAR(20) DEFAULT 'Retail'
        CHECK (CustomerType IN ('Retail', 'Wholesale', 'Corporate', 'Government')),
    CreditLimit DECIMAL(15,2) DEFAULT 5000.00,
    IsActive BIT DEFAULT 1,
    Notes NVARCHAR(MAX),
    -- Additional columns for wide table scenario
    Preferences XML NULL,
    ProfileImage VARBINARY(MAX) NULL,
    AuditTrail XML NULL
);
GO

-- Create Products table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode AS ('PROD' + RIGHT('0000' + CAST(ProductID AS VARCHAR(4)), 4)) PERSISTED,
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    SubCategory NVARCHAR(50),
    Brand NVARCHAR(50),
    SupplierID INT,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CostPrice DECIMAL(10,2) NOT NULL,
    QuantityInStock INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10,
    MinimumOrderQuantity INT DEFAULT 1,
    MaximumOrderQuantity INT DEFAULT 100,
    Weight DECIMAL(8,2),
    Dimensions NVARCHAR(50),
    Color NVARCHAR(30),
    Size NVARCHAR(30),
    Material NVARCHAR(50),
    Description NVARCHAR(500),
    LongDescription NVARCHAR(MAX),
    Specifications XML,
    IsDiscontinued BIT DEFAULT 0,
    DiscontinuedDate DATE NULL,
    ReleaseDate DATE DEFAULT GETDATE(),
    LastRestockDate DATE NULL,
    Rating DECIMAL(3,2) DEFAULT 0.00,
    ReviewCount INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    -- Check constraints
    CONSTRAINT CHK_Products_Price CHECK (UnitPrice > 0 AND CostPrice > 0),
    CONSTRAINT CHK_Products_Stock CHECK (QuantityInStock >= 0),
    CONSTRAINT CHK_Products_Rating CHECK (Rating BETWEEN 0 AND 5)
);
GO

-- Create Orders table (will be populated with 500,000+ rows)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber AS ('ORD' + RIGHT('000000' + CAST(OrderID AS VARCHAR(6)), 6)) PERSISTED,
    CustomerID INT NOT NULL,
    EmployeeID INT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATE NULL,
    ShippedDate DATETIME NULL,
    ShipVia VARCHAR(50),
    Freight DECIMAL(10,2) DEFAULT 0.00,
    ShipName NVARCHAR(100),
    ShipAddress NVARCHAR(200),
    ShipCity NVARCHAR(50),
    ShipRegion NVARCHAR(50),
    ShipPostalCode VARCHAR(20),
    ShipCountry NVARCHAR(50),
    OrderStatus VARCHAR(20) DEFAULT 'Pending'
        CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'On Hold', 'Returned')),
    PaymentMethod VARCHAR(30),
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid',
    TaxAmount DECIMAL(10,2) DEFAULT 0.00,
    DiscountAmount DECIMAL(10,2) DEFAULT 0.00,
    OrderTotal AS (
        ISNULL((SELECT SUM(UnitPrice * Quantity * (1 - Discount/100)) 
                FROM OrderDetails WHERE OrderID = Orders.OrderID), 0) 
        + Freight + TaxAmount - DiscountAmount
    ) PERSISTED,
    -- Foreign keys
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),
    -- Check constraints
    CONSTRAINT CHK_Orders_Dates CHECK (OrderDate <= ISNULL(ShippedDate, '9999-12-31')),
    CONSTRAINT CHK_Orders_Freight CHECK (Freight >= 0),
    CONSTRAINT CHK_Orders_Tax CHECK (TaxAmount >= 0),
    CONSTRAINT CHK_Orders_Discount CHECK (DiscountAmount >= 0)
);
GO

-- Create OrderDetails table (will be populated with 2,000,000+ rows)
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    Discount DECIMAL(5,2) DEFAULT 0.00,
    -- Computed columns
    LineTotal AS (UnitPrice * Quantity * (1 - Discount/100)) PERSISTED,
    -- Foreign keys
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),
    -- Check constraints
    CONSTRAINT CHK_OrderDetails_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_OrderDetails_Discount CHECK (Discount BETWEEN 0 AND 100),
    CONSTRAINT CHK_OrderDetails_Price CHECK (UnitPrice >= 0)
);
GO

-- Create Employees table for additional relationships
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    HireDate DATE NOT NULL,
    JobTitle NVARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10,2) NOT NULL,
    CommissionPct DECIMAL(5,2) DEFAULT 0.00,
    ManagerID INT NULL,
    IsActive BIT DEFAULT 1,
    -- Check constraints
    CONSTRAINT CHK_Employees_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Employees_Commission CHECK (CommissionPct BETWEEN 0 AND 100)
);
GO

-- Add foreign key to Orders table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID)
    REFERENCES Employees(EmployeeID);
GO

-- Create AuditLog table for monitoring
CREATE TABLE AuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    Operation CHAR(1) CHECK (Operation IN ('I', 'U', 'D')),
    KeyValue NVARCHAR(100),
    OldData XML,
    NewData XML,
    ChangedBy NVARCHAR(100) DEFAULT SYSTEM_USER,
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO

-- Create index fragmentation monitoring table
CREATE TABLE IndexMaintenanceLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    IndexName NVARCHAR(128) NOT NULL,
    FragmentationPercent DECIMAL(5,2),
    PageCount INT,
    Operation VARCHAR(50),
    StartTime DATETIME DEFAULT GETDATE(),
    EndTime DATETIME NULL,
    DurationSeconds AS (DATEDIFF(SECOND, StartTime, ISNULL(EndTime, GETDATE()))) PERSISTED
);
GO

-- Section 2: Fundamental Concepts - Clustered Indexes
--------------------------------------------------------------------
-- Clustered Index: Determines physical order of data in table
-- Only one per table, typically on primary key
--------------------------------------------------------------------

PRINT '=== SECTION 2: CLUSTERED INDEXES ===';

-- 2.1 Table already has clustered index on primary key (CustomerID)
-- Let's verify the clustered index
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key AS IsPrimaryKey,
    c.name AS ColumnName,
    ic.key_ordinal AS KeyOrdinal
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE t.name = 'Customers'
    AND i.type = 1  -- Clustered index
ORDER BY ic.key_ordinal;
GO

-- 2.2 Create a table without clustered index to demonstrate difference
CREATE TABLE Customers_Heap (
    CustomerID INT IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    City NVARCHAR(50)
);
GO

-- Insert sample data
INSERT INTO Customers_Heap (FirstName, LastName, Email, City)
VALUES 
    ('John', 'Smith', 'john@example.com', 'New York'),
    ('Maria', 'Garcia', 'maria@example.com', 'Chicago'),
    ('David', 'Chen', 'david@example.com', 'San Francisco');
GO

-- Check table structure (Heap table - no clustered index)
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key AS IsPrimaryKey
FROM sys.tables t
LEFT JOIN sys.indexes i ON t.object_id = i.object_id
WHERE t.name = 'Customers_Heap'
ORDER BY i.type;
GO

-- 2.3 Add clustered index to heap table
CREATE CLUSTERED INDEX IX_CustomersHeap_CustomerID 
ON Customers_Heap(CustomerID);
GO

-- Verify clustered index was created
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
WHERE t.name = 'Customers_Heap'
    AND i.type = 1;
GO

-- 2.4 Create a clustered index on a non-primary key column
-- First, drop the existing clustered index
DROP INDEX IX_CustomersHeap_CustomerID ON Customers_Heap;
GO

-- Create clustered index on Email (must be unique)
CREATE UNIQUE CLUSTERED INDEX IX_CustomersHeap_Email 
ON Customers_Heap(Email);
GO

-- Verify
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    c.name AS ColumnName
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE t.name = 'Customers_Heap'
    AND i.type = 1;
GO

-- Clean up
DROP TABLE Customers_Heap;
GO

-- Section 3: Core Functionality - Non-Clustered Indexes
--------------------------------------------------------------------
-- Non-Clustered Index: Separate structure with pointers to data
-- Multiple per table, created on frequently queried columns
--------------------------------------------------------------------

PRINT '=== SECTION 3: NON-CLUSTERED INDEXES ===';

-- 3.1 Create basic non-clustered index on single column
-- Index on Email for fast lookups
CREATE NONCLUSTERED INDEX IX_Customers_Email 
ON Customers(Email);
GO

-- 3.2 Create non-clustered index on multiple columns (composite index)
-- Index for queries filtering by City and State
CREATE NONCLUSTERED INDEX IX_Customers_CityState 
ON Customers(City, State);
GO

-- 3.3 Create unique non-clustered index
-- Ensure Email uniqueness (alternative to UNIQUE constraint)
CREATE UNIQUE NONCLUSTERED INDEX UIX_Customers_EmailUnique 
ON Customers(Email);
-- Note: This will fail if duplicate emails exist
GO

-- 3.4 Create filtered index (index on subset of rows)
-- Index only active customers
CREATE NONCLUSTERED INDEX IX_Customers_ActiveOnly 
ON Customers(CustomerID)
WHERE IsActive = 1;
GO

-- 3.5 Create index with included columns (covering index)
-- Index for queries that need CustomerID, FirstName, LastName, Email
CREATE NONCLUSTERED INDEX IX_Customers_NameLookup 
ON Customers(LastName, FirstName)
INCLUDE (Email, Phone);
GO

-- 3.6 Create descending index for ORDER BY ... DESC queries
CREATE NONCLUSTERED INDEX IX_Customers_RegistrationDateDesc 
ON Customers(RegistrationDate DESC);
GO

-- 3.7 Verify all created indexes
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    i.has_filter AS HasFilter,
    i.filter_definition AS FilterDefinition,
    STUFF((
        SELECT ', ' + c.name + 
               CASE WHEN ic.is_included_column = 1 THEN ' (INCLUDED)' 
                    WHEN ic.key_ordinal > 0 THEN ' (KEY ' + CAST(ic.key_ordinal AS VARCHAR) + ')'
                    ELSE '' END
        FROM sys.index_columns ic
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
        ORDER BY ic.key_ordinal, ic.index_column_id
        FOR XML PATH('')
    ), 1, 2, '') AS IndexColumns
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
WHERE t.name = 'Customers'
    AND i.type IN (1, 2)  -- Clustered and Non-Clustered
ORDER BY i.type, i.name;
GO

-- Section 4: Index Creation with Advanced Options
--------------------------------------------------------------------
-- Using advanced index options: FILLFACTOR, PAD_INDEX, SORT_IN_TEMPDB
--------------------------------------------------------------------

PRINT '=== SECTION 4: ADVANCED INDEX OPTIONS ===';

-- 4.1 Create index with FILLFACTOR (leaves free space for updates)
-- 80% fill - leaves 20% free space on each page
CREATE NONCLUSTERED INDEX IX_Customers_City_FillFactor 
ON Customers(City)
WITH (FILLFACTOR = 80);
GO

-- 4.2 Create index with PAD_INDEX (applies FILLFACTOR to intermediate levels)
CREATE NONCLUSTERED INDEX IX_Customers_State_Padded 
ON Customers(State)
WITH (PAD_INDEX = ON, FILLFACTOR = 70);
GO

-- 4.3 Create index with SORT_IN_TEMPDB (uses tempdb for sorting)
-- Useful when tempdb is on faster storage
CREATE NONCLUSTERED INDEX IX_Customers_Country_SortedInTempDB 
ON Customers(Country)
WITH (SORT_IN_TEMPDB = ON);
GO

-- 4.4 Create index with STATISTICS_NORECOMPUTE
-- Manually control statistics updates
CREATE NONCLUSTERED INDEX IX_Customers_PostalCode_NoRecompute 
ON Customers(PostalCode)
WITH (STATISTICS_NORECOMPUTE = ON);
GO

-- 4.5 Create index with DATA_COMPRESSION
-- Reduces storage and I/O (Enterprise edition feature)
-- Note: Uncomment if you have Enterprise edition
/*
CREATE NONCLUSTERED INDEX IX_Customers_City_Compressed 
ON Customers(City)
WITH (DATA_COMPRESSION = PAGE);  -- PAGE or ROW compression
GO
*/

-- 4.6 Create index with MAXDOP (Maximum Degree of Parallelism)
-- Control parallelism during index creation
CREATE NONCLUSTERED INDEX IX_Customers_LastName_MaxDOP 
ON Customers(LastName)
WITH (MAXDOP = 2);  -- Use only 2 processors
GO

-- 4.7 Create index online (available in Enterprise edition)
-- Allows concurrent access during index creation
-- Note: Uncomment if you have Enterprise edition
/*
CREATE NONCLUSTERED INDEX IX_Customers_FirstName_Online 
ON Customers(FirstName)
WITH (ONLINE = ON);
GO
*/

-- Section 5: Performance Demonstration - Before and After Indexing
--------------------------------------------------------------------
-- Demonstrate performance impact of indexes
--------------------------------------------------------------------

PRINT '=== SECTION 5: PERFORMANCE DEMONSTRATION ===';

-- First, populate tables with large amount of data
PRINT 'Populating tables with sample data...';

-- Insert 10,000 customers
INSERT INTO Customers (FirstName, LastName, Email, City, State, Country, RegistrationDate)
SELECT 
    'FirstName_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'LastName_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'email' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)) + '@example.com',
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 0 THEN 'New York'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 1 THEN 'Chicago'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 2 THEN 'San Francisco'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 3 THEN 'Boston'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 4 THEN 'Austin'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 5 THEN 'Seattle'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 6 THEN 'Miami'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 7 THEN 'Denver'
         WHEN ROW_NUMBER() OVER (SELECT NULL)) % 10 = 8 THEN 'Atlanta'
         ELSE 'Phoenix' END,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 0 THEN 'NY'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 1 THEN 'IL'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 2 THEN 'CA'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 3 THEN 'TX'
         ELSE 'FL' END,
    'USA',
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())
FROM sys.all_columns a1
CROSS JOIN sys.all_columns a2
WHERE ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) <= 10000;
GO

-- Insert 100 products
INSERT INTO Products (ProductName, Category, UnitPrice, CostPrice, QuantityInStock)
SELECT 
    'Product ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 0 THEN 'Electronics'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 1 THEN 'Clothing'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 2 THEN 'Home'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 5 = 3 THEN 'Books'
         ELSE 'Sports' END,
    (ABS(CHECKSUM(NEWID())) % 1000) + 10.00,
    (ABS(CHECKSUM(NEWID())) % 500) + 5.00,
    ABS(CHECKSUM(NEWID())) % 1000
FROM sys.all_columns
WHERE ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) <= 100;
GO

-- Insert 50 employees
INSERT INTO Employees (FirstName, LastName, Email, HireDate, JobTitle, Department, Salary)
SELECT 
    'EmployeeFirst_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'EmployeeLast_' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)),
    'employee' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)) + '@company.com',
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1000, GETDATE()),
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 4 = 0 THEN 'Manager'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 4 = 1 THEN 'Developer'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 4 = 2 THEN 'Sales'
         ELSE 'Support' END,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 3 = 0 THEN 'IT'
         WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 3 = 1 THEN 'Sales'
         ELSE 'HR' END,
    (ABS(CHECKSUM(NEWID())) % 80000) + 40000.00
FROM sys.all_columns
WHERE ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) <= 50;
GO

-- Insert 5,000 orders
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, OrderStatus, City, State)
SELECT 
    (ABS(CHECKSUM(NEWID())) % 10000) + 1,
    (ABS(CHECKSUM(NEWID())) % 50) + 1,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()),
    CASE WHEN ABS(CHECKSUM(NEWID())) % 10 = 0 THEN 'Pending'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 1 THEN 'Processing'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 2 THEN 'On Hold'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 3 THEN 'Cancelled'
         ELSE 'Delivered' END,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 10 = 0 THEN 'New York'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 1 THEN 'Chicago'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 2 THEN 'San Francisco'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 3 THEN 'Boston'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 4 THEN 'Austin'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 5 THEN 'Seattle'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 6 THEN 'Miami'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 7 THEN 'Denver'
         WHEN ABS(CHECKSUM(NEWID())) % 10 = 8 THEN 'Atlanta'
         ELSE 'Phoenix' END,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 5 = 0 THEN 'NY'
         WHEN ABS(CHECKSUM(NEWID())) % 5 = 1 THEN 'IL'
         WHEN ABS(CHECKSUM(NEWID())) % 5 = 2 THEN 'CA'
         WHEN ABS(CHECKSUM(NEWID())) % 5 = 3 THEN 'TX'
         ELSE 'FL' END
FROM sys.all_columns a1
CROSS JOIN sys.all_columns a2
WHERE ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) <= 5000;
GO

-- Insert 20,000 order details
INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT 
    (ABS(CHECKSUM(NEWID())) % 5000) + 1,
    (ABS(CHECKSUM(NEWID())) % 100) + 1,
    (ABS(CHECKSUM(NEWID())) % 500) + 10.00,
    (ABS(CHECKSUM(NEWID())) % 10) + 1,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 4 = 0 THEN 5.00
         WHEN ABS(CHECKSUM(NEWID())) % 4 = 1 THEN 10.00
         WHEN ABS(CHECKSUM(NEWID())) % 4 = 2 THEN 15.00
         ELSE 0.00 END
FROM sys.all_columns a1
CROSS JOIN sys.all_columns a2
WHERE ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) <= 20000;
GO

PRINT 'Data population completed.';
GO

-- 5.1 Demonstrate query without index
PRINT '=== Query WITHOUT index on City column ===';

-- Drop index if it exists
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Customers_City' AND object_id = OBJECT_ID('Customers'))
    DROP INDEX IX_Customers_City ON Customers;
GO

-- Clear cache for accurate comparison (development only!)
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

-- Query without index (table scan)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT CustomerID, FirstName, LastName, City, State
FROM Customers
WHERE City = 'New York'
ORDER BY LastName, FirstName;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 5.2 Demonstrate query with index
PRINT '=== Query WITH index on City column ===';

-- Create index
CREATE NONCLUSTERED INDEX IX_Customers_City 
ON Customers(City)
INCLUDE (FirstName, LastName, State);
GO

-- Clear cache
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

-- Query with index (index seek)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT CustomerID, FirstName, LastName, City, State
FROM Customers
WHERE City = 'New York'
ORDER BY LastName, FirstName;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 5.3 Demonstrate covering index benefits
PRINT '=== Covering Index Example ===';

-- Query that needs additional lookups
SET STATISTICS IO ON;

SELECT CustomerID, FirstName, LastName, Email, Phone
FROM Customers
WHERE LastName LIKE 'Smith%'
    AND FirstName LIKE 'J%';

SET STATISTICS IO OFF;
GO

-- Create covering index
CREATE NONCLUSTERED INDEX IX_Customers_NameCovering 
ON Customers(LastName, FirstName)
INCLUDE (Email, Phone);
GO

-- Clear cache and test again
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;

SELECT CustomerID, FirstName, LastName, Email, Phone
FROM Customers
WHERE LastName LIKE 'Smith%'
    AND FirstName LIKE 'J%';

SET STATISTICS IO OFF;
GO

-- Section 6: Index Types - Filtered, Columnstore, Full-Text
--------------------------------------------------------------------
-- Specialized index types for specific scenarios
--------------------------------------------------------------------

PRINT '=== SECTION 6: SPECIALIZED INDEX TYPES ===';

-- 6.1 Filtered Indexes (already demonstrated, more examples)
-- Create filtered index for high-value customers
CREATE NONCLUSTERED INDEX IX_Customers_HighValue 
ON Customers(CustomerID, TotalSpent)
WHERE TotalSpent > 10000.00;
GO

-- Create filtered index for specific date range
CREATE NONCLUSTERED INDEX IX_Customers_RecentRegistrations 
ON Customers(RegistrationDate)
WHERE RegistrationDate >= '2024-01-01';
GO

-- 6.2 Columnstore Indexes (for data warehousing/analytics)
-- Create a columnstore index for analytical queries
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_OrderDetails_Columnstore 
ON OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount, LineTotal);
GO

-- Test columnstore index performance
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Analytical query that benefits from columnstore
SELECT 
    p.Category,
    COUNT(*) AS OrderCount,
    SUM(od.Quantity) AS TotalQuantity,
    SUM(od.LineTotal) AS TotalRevenue,
    AVG(od.Discount) AS AverageDiscount
FROM OrderDetails od
INNER JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 6.3 Full-Text Index (requires full-text catalog)
-- Note: Setup requires additional configuration
/*
-- Enable full-text if not enabled
EXEC sp_fulltext_database 'enable';

-- Create full-text catalog
CREATE FULLTEXT CATALOG FTCatalog AS DEFAULT;

-- Create full-text index on Products description
CREATE FULLTEXT INDEX ON Products(Description, LongDescription)
KEY INDEX PK__Products__ProductID
ON FTCatalog
WITH CHANGE_TRACKING AUTO;
GO

-- Search using full-text
SELECT ProductID, ProductName, Description
FROM Products
WHERE CONTAINS((Description, LongDescription), 'wireless AND battery');
GO
*/

-- 6.4 Spatial Index (for geographic data)
-- Create table with spatial data
CREATE TABLE Locations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationName NVARCHAR(100),
    GeoPoint GEOGRAPHY,
    Address NVARCHAR(200)
);
GO

-- Create spatial index
CREATE SPATIAL INDEX IX_Locations_GeoPoint 
ON Locations(GeoPoint)
WITH (BOUNDING_BOX = (-180, -90, 180, 90));
GO

-- Clean up
DROP TABLE Locations;
GO

-- Section 7: Index Management and Maintenance
--------------------------------------------------------------------
-- Monitoring, rebuilding, reorganizing, and dropping indexes
--------------------------------------------------------------------

PRINT '=== SECTION 7: INDEX MAINTENANCE ===';

-- 7.1 View index fragmentation
SELECT 
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc AS IndexType,
    ips.avg_fragmentation_in_percent AS FragmentationPercent,
    ips.page_count AS PageCount,
    ips.avg_page_space_used_in_percent AS PageSpaceUsedPercent,
    ips.record_count AS RecordCount
FROM sys.dm_db_index_physical_stats(
    DB_ID(), 
    OBJECT_ID('Customers'), 
    NULL, NULL, 'DETAILED') ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 0
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO

-- 7.2 Reorganize index (for fragmentation 5-30%)
ALTER INDEX IX_Customers_City ON Customers REORGANIZE;
GO

-- 7.3 Rebuild index (for fragmentation > 30%)
ALTER INDEX IX_Customers_Email ON Customers REBUILD;
GO

-- 7.4 Rebuild index with options
ALTER INDEX IX_Customers_CityState ON Customers REBUILD
WITH (
    FILLFACTOR = 90,
    SORT_IN_TEMPDB = ON,
    STATISTICS_NORECOMPUTE = OFF,
    ONLINE = OFF  -- Change to ON for Enterprise edition
);
GO

-- 7.5 Disable and enable index
-- Disable index
ALTER INDEX IX_Customers_NameLookup ON Customers DISABLE;
GO

-- Try to use disabled index (will fail or cause scan)
SELECT * FROM Customers WITH (INDEX(IX_Customers_NameLookup))
WHERE LastName = 'Smith';
GO

-- Enable index (rebuilds it)
ALTER INDEX IX_Customers_NameLookup ON Customers REBUILD;
GO

-- 7.6 Drop index
DROP INDEX IX_Customers_City_FillFactor ON Customers;
GO

-- 7.7 Rename index
EXEC sp_rename 
    @objname = 'Customers.IX_Customers_CityState',
    @newname = 'IX_Customers_ByCityState',
    @objtype = 'INDEX';
GO

-- 7.8 Update index statistics
UPDATE STATISTICS Customers IX_Customers_Email
WITH FULLSCAN;  -- Or SAMPLE, RESAMPLE
GO

-- Section 8: Index Monitoring and Analysis
--------------------------------------------------------------------
-- Using DMVs to monitor index usage and performance
--------------------------------------------------------------------

PRINT '=== SECTION 8: INDEX MONITORING ===';

-- 8.1 View index usage statistics
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    us.user_seeks,
    us.user_scans,
    us.user_lookups,
    us.user_updates,
    us.last_user_seek,
    us.last_user_scan,
    us.last_user_lookup,
    us.last_user_update
FROM sys.dm_db_index_usage_stats us
JOIN sys.indexes i ON us.object_id = i.object_id AND us.index_id = i.index_id
WHERE us.database_id = DB_ID()
    AND OBJECT_NAME(i.object_id) IN ('Customers', 'Orders', 'Products', 'OrderDetails')
ORDER BY us.user_seeks + us.user_scans DESC;
GO

-- 8.2 Identify unused indexes (potential for removal)
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    SUM(s.user_seeks + s.user_scans + s.user_lookups) AS TotalReads,
    s.user_updates AS Writes,
    CASE 
        WHEN SUM(s.user_seeks + s.user_scans + s.user_lookups) = 0 
        THEN 'UNUSED'
        WHEN s.user_updates > (SUM(s.user_seeks + s.user_scans + s.user_lookups) * 10)
        THEN 'HIGH WRITE/LOW READ'
        ELSE 'USED'
    END AS UsageStatus
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE i.object_id = OBJECT_ID('Customers')
    AND s.database_id = DB_ID()
GROUP BY OBJECT_NAME(i.object_id), i.name, i.type_desc, s.user_updates
ORDER BY TotalReads;
GO

-- 8.3 View missing index recommendations
SELECT 
    migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS ImprovementMeasure,
    OBJECT_NAME(mid.object_id) AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.user_seeks,
    migs.user_scans,
    migs.last_user_seek,
    migs.avg_total_user_cost,
    migs.avg_user_impact
FROM sys.d
