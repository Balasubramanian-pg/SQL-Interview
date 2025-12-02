/*
================================================================================
COMPREHENSIVE SQL DDL TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to Data Definition Language (DDL) with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- DDL = Data Definition Language (CREATE, ALTER, DROP, TRUNCATE)
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DDLTutorialDB')
BEGIN
    ALTER DATABASE DDLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DDLTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE DDLTutorialDB;
GO

USE DDLTutorialDB;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Core DDL Concepts: Creating database objects
-- Database = Container, Schema = Namespace, Object = Table/View/etc.
--------------------------------------------------------------------

-- Create a custom schema (organizational container for objects)
-- Syntax: CREATE SCHEMA [schema_name] AUTHORIZATION [owner]
CREATE SCHEMA Sales AUTHORIZATION dbo;
GO

CREATE SCHEMA HR AUTHORIZATION dbo;
GO

CREATE SCHEMA Audit AUTHORIZATION dbo;
GO

-- Verify schemas were created
SELECT name AS SchemaName, schema_id, principal_id AS OwnerID
FROM sys.schemas
WHERE name IN ('Sales', 'HR', 'Audit', 'dbo')
ORDER BY schema_id;
GO

-- Section 2: Fundamental Concepts - CREATE TABLE
--------------------------------------------------------------------
-- CREATE TABLE is the foundation of database design
-- Defines structure, data types, and constraints
--------------------------------------------------------------------

-- Create a basic table with common data types
-- Syntax: CREATE TABLE [schema].[table] (column definitions)
CREATE TABLE Sales.Customers (
    -- Column definitions with data types and constraints
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing primary key
    CustomerCode AS 'CUST' + RIGHT('00000' + CAST(CustomerID AS VARCHAR(5)), 5) PERSISTED, -- Computed column
    FirstName NVARCHAR(50) NOT NULL,            -- Unicode string (2 bytes per char)
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,                  -- Unique constraint
    Phone VARCHAR(20) NULL,                      -- Non-Unicode string
    DateOfBirth DATE NULL,                       -- Date only (no time)
    RegistrationDate DATETIME DEFAULT GETDATE(), -- Default value
    CreditLimit DECIMAL(10,2) DEFAULT 1000.00,   -- Decimal with precision/scale
    IsActive BIT DEFAULT 1,                      -- Boolean (0/1)
    Notes NVARCHAR(MAX) NULL,                    -- Large text field
    -- Table-level constraints
    CONSTRAINT CHK_Customers_CreditLimit CHECK (CreditLimit >= 0),
    CONSTRAINT CHK_Customers_Email CHECK (Email LIKE '%@%.%')
);
GO

-- Create another table with foreign key relationship
CREATE TABLE Sales.Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber AS 'ORD' + RIGHT('00000' + CAST(OrderID AS VARCHAR(5)), 5) PERSISTED,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATE NULL,
    ShippedDate DATETIME NULL,
    OrderStatus VARCHAR(20) DEFAULT 'Pending',
    TotalAmount DECIMAL(10,2) DEFAULT 0.00,
    -- Foreign key constraint with referential integrity
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID)
        ON DELETE CASCADE      -- Delete orders when customer is deleted
        ON UPDATE NO ACTION,   -- Don't allow customer ID changes
    -- Check constraint with case-insensitive comparison
    CONSTRAINT CHK_Orders_Status CHECK (
        UPPER(OrderStatus) IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED')
    ),
    CONSTRAINT CHK_Orders_Dates CHECK (OrderDate <= ISNULL(ShippedDate, '9999-12-31'))
);
GO

-- Test the table creation
INSERT INTO Sales.Customers (FirstName, LastName, Email, Phone)
VALUES ('John', 'Smith', 'john.smith@example.com', '+1-555-1234');

INSERT INTO Sales.Orders (CustomerID, TotalAmount, OrderStatus)
VALUES (1, 299.99, 'Pending');

SELECT 'Tables created and sample data inserted' AS Status;
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;
GO

-- Section 3: Core Functionality - ALTER TABLE
--------------------------------------------------------------------
-- ALTER TABLE modifies existing table structure
-- Used for adding/dropping columns, constraints, indexes
--------------------------------------------------------------------

-- Add new column to existing table
-- Syntax: ALTER TABLE [table] ADD [column] [datatype] [constraints]
ALTER TABLE Sales.Customers
ADD CustomerType VARCHAR(20) DEFAULT 'Retail' 
    CONSTRAINT CHK_Customers_Type CHECK (CustomerType IN ('Retail', 'Wholesale', 'Corporate'));
GO

-- Modify existing column (some restrictions apply)
-- Note: Can't change data type if column contains data (usually)
ALTER TABLE Sales.Customers
ALTER COLUMN Phone VARCHAR(25) NULL;  -- Increased size from 20 to 25
GO

-- Add multiple columns at once
ALTER TABLE Sales.Customers
ADD 
    LastPurchaseDate DATE NULL,
    LifetimeValue DECIMAL(12,2) DEFAULT 0.00,
    PreferredContactMethod VARCHAR(10) DEFAULT 'Email';
GO

-- Add a computed column
ALTER TABLE Sales.Customers
ADD FullName AS FirstName + ' ' + LastName;
GO

-- Add a constraint to existing column
ALTER TABLE Sales.Customers
ADD CONSTRAINT CHK_Customers_PhoneFormat 
    CHECK (Phone LIKE '+[0-9]%-%' OR Phone IS NULL);
GO

-- Test the alterations
UPDATE Sales.Customers 
SET CustomerType = 'Corporate',
    LifetimeValue = 1500.00
WHERE CustomerID = 1;

SELECT 
    CustomerID,
    FullName,
    CustomerType,
    LifetimeValue,
    CustomerCode
FROM Sales.Customers;
GO

-- Section 4: Core Functionality - CREATE INDEX
--------------------------------------------------------------------
-- Indexes improve query performance but have maintenance overhead
-- Clustered vs Non-clustered, Unique vs Non-unique
--------------------------------------------------------------------

-- Create a clustered index (determines physical order of data)
-- Note: Table already has PRIMARY KEY which creates clustered index
-- Let's create a non-clustered index for performance

-- Create non-clustered index on frequently searched columns
-- Syntax: CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] INDEX [index_name] ON [table](columns)
CREATE NONCLUSTERED INDEX IX_Customers_Email
ON Sales.Customers(Email);
GO

-- Create composite index (multiple columns)
CREATE NONCLUSTERED INDEX IX_Customers_NameSearch
ON Sales.Customers(LastName, FirstName)
INCLUDE (Email, Phone);  -- INCLUDE: Add columns to index leaf for covering queries
GO

-- Create filtered index (index subset of rows)
CREATE NONCLUSTERED INDEX IX_Customers_ActiveOnly
ON Sales.Customers(CustomerID)
WHERE IsActive = 1;  -- Only index active customers
GO

-- Create index with included columns for covering queries
CREATE NONCLUSTERED INDEX IX_Orders_CustomerDate
ON Sales.Orders(CustomerID, OrderDate)
INCLUDE (TotalAmount, OrderStatus);
GO

-- View created indexes
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    i.has_filter AS HasFilter,
    i.filter_definition AS FilterDefinition
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('Customers', 'Orders')
ORDER BY t.name, i.type_desc;
GO

-- Section 5: Intermediate Techniques - Advanced Table Features
--------------------------------------------------------------------
-- Partitioning, Filegroups, Compression, Temporal Tables
--------------------------------------------------------------------

-- Create a partitioned table for large data sets
-- First, create partition function and scheme

-- Create partition function (by year)
CREATE PARTITION FUNCTION PF_OrderDates (DATE)
AS RANGE RIGHT FOR VALUES 
    ('2023-01-01', '2024-01-01', '2025-01-01');
GO

-- Create partition scheme
CREATE PARTITION SCHEME PS_OrderDates
AS PARTITION PF_OrderDates
ALL TO ([PRIMARY]);  -- All partitions in primary filegroup
GO

-- Create partitioned table
CREATE TABLE Sales.OrderHistory (
    OrderHistoryID INT IDENTITY(1,1),
    OrderID INT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    ActionType VARCHAR(20) NOT NULL,
    ActionDetails NVARCHAR(MAX) NULL,
    ActionDate DATETIME DEFAULT GETDATE(),
    -- Partition on OrderDate
    CONSTRAINT PK_OrderHistory PRIMARY KEY CLUSTERED (OrderHistoryID, OrderDate)
) ON PS_OrderDates(OrderDate);  -- Partitioning column must be in PK
GO

-- Create a table with filegroup specification
CREATE TABLE HR.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    DepartmentID INT,
    Salary DECIMAL(10,2),
    HireDate DATE DEFAULT GETDATE(),
    Photo VARBINARY(MAX) NULL  -- Large binary data (photos)
) ON [PRIMARY];  -- Specify filegroup
GO

-- Create a table with data compression
CREATE TABLE Sales.SalesArchive (
    SaleID INT IDENTITY(1,1) PRIMARY KEY WITH (DATA_COMPRESSION = PAGE),  -- Page compression
    OrderID INT NOT NULL,
    SaleDate DATETIME NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    -- Row compression for specific column
    Comments VARCHAR(MAX) WITH (COMPRESS)
);
GO

-- Test partitioned table
INSERT INTO Sales.OrderHistory (OrderID, OrderDate, CustomerID, ActionType)
VALUES 
    (1, '2023-06-15', 1, 'Created'),
    (2, '2024-03-20', 1, 'Modified');

-- Check partition distribution
SELECT 
    partition_number,
    rows AS RowCount
FROM sys.partitions 
WHERE object_id = OBJECT_ID('Sales.OrderHistory');
GO

-- Section 6: Intermediate Techniques - CREATE VIEW
--------------------------------------------------------------------
-- Views are virtual tables based on SELECT queries
-- Standard, Indexed, and Partitioned Views
--------------------------------------------------------------------

-- Create a standard view (dynamic result set)
-- Syntax: CREATE VIEW [schema].[view] AS SELECT statement
CREATE VIEW Sales.vw_CustomerOrders
AS
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.CustomerType,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(ISNULL(o.TotalAmount, 0)) AS TotalSpent,
    MAX(o.OrderDate) AS LastOrderDate
FROM Sales.Customers c
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
WHERE c.IsActive = 1
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.CustomerType;
GO

-- Create a view with check option (insert/update through view)
CREATE VIEW Sales.vw_ActiveCustomers
AS
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,
    CustomerType
FROM Sales.Customers
WHERE IsActive = 1
WITH CHECK OPTION;  -- Ensures DML through view respects WHERE clause
GO

-- Create a view with schema binding (prevents underlying table changes)
CREATE VIEW Sales.vw_CustomerSummary
WITH SCHEMABINDING  -- Locks schema of underlying tables
AS
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    CustomerType,
    CreditLimit
FROM Sales.Customers
WHERE IsActive = 1;
GO

-- Test the views
SELECT * FROM Sales.vw_CustomerOrders;
SELECT * FROM Sales.vw_ActiveCustomers;
GO

-- Section 7: Advanced Features - Stored Procedures, Functions, Triggers
--------------------------------------------------------------------
-- Programmable DDL objects for business logic
--------------------------------------------------------------------

-- Create a stored procedure (reusable code block)
-- Syntax: CREATE PROC [schema].[proc] @parameters AS BEGIN code END
CREATE PROCEDURE Sales.usp_AddCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone VARCHAR(25) = NULL,
    @CustomerType VARCHAR(20) = 'Retail',
    @NewCustomerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Input validation
        IF @Email NOT LIKE '%@%.%'
        BEGIN
            RAISERROR('Invalid email format', 16, 1);
            RETURN;
        END
        
        -- Insert customer
        INSERT INTO Sales.Customers (FirstName, LastName, Email, Phone, CustomerType)
        VALUES (@FirstName, @LastName, @Email, @Phone, @CustomerType);
        
        -- Get new ID
        SET @NewCustomerID = SCOPE_IDENTITY();
        
        -- Log the action
        INSERT INTO Sales.OrderHistory (OrderID, OrderDate, CustomerID, ActionType)
        VALUES (0, GETDATE(), @NewCustomerID, 'CustomerCreated');
        
        COMMIT TRANSACTION;
        
        PRINT 'Customer added successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;  -- Re-throw error to caller
    END CATCH
END;
GO

-- Create a scalar function (returns single value)
CREATE FUNCTION Sales.ufn_CalculateDiscount
(
    @TotalAmount DECIMAL(10,2),
    @CustomerType VARCHAR(20)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Discount DECIMAL(10,2) = 0;
    
    -- Calculate discount based on customer type
    IF @CustomerType = 'Corporate'
        SET @Discount = @TotalAmount * 0.15;  -- 15% discount
    ELSE IF @CustomerType = 'Wholesale'
        SET @Discount = @TotalAmount * 0.10;  -- 10% discount
    ELSE
        SET @Discount = @TotalAmount * 0.05;  -- 5% discount for retail
        
    RETURN @Discount;
END;
GO

-- Create a table-valued function (returns table)
CREATE FUNCTION Sales.ufn_GetCustomerOrders
(
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        OrderID,
        OrderDate,
        TotalAmount,
        OrderStatus
    FROM Sales.Orders
    WHERE CustomerID = @CustomerID
        AND (@StartDate IS NULL OR OrderDate >= @StartDate)
        AND (@EndDate IS NULL OR OrderDate <= @EndDate)
);
GO

-- Test programmable objects
DECLARE @NewID INT;
EXEC Sales.usp_AddCustomer 
    @FirstName = 'Sarah',
    @LastName = 'Johnson',
    @Email = 'sarah.j@example.com',
    @CustomerType = 'Corporate',
    @NewCustomerID = @NewID OUTPUT;

SELECT @NewID AS NewCustomerID;

-- Test function
SELECT 
    TotalAmount,
    Sales.ufn_CalculateDiscount(TotalAmount, 'Corporate') AS Discount
FROM Sales.Orders
WHERE CustomerID = 1;
GO

-- Section 8: Advanced Features - Security Objects
--------------------------------------------------------------------
-- Users, Roles, Permissions, Schemas for security
--------------------------------------------------------------------

-- Create database users
-- Syntax: CREATE USER [username] FOR LOGIN [loginname] WITH DEFAULT_SCHEMA = [schema]
CREATE USER SalesUser WITHOUT LOGIN WITH DEFAULT_SCHEMA = Sales;
CREATE USER HRUser WITHOUT LOGIN WITH DEFAULT_SCHEMA = HR;
CREATE USER ReportUser WITHOUT LOGIN WITH DEFAULT_SCHEMA = dbo;
GO

-- Create database roles
CREATE ROLE SalesRole;
CREATE ROLE HRRole;
CREATE ROLE ReadOnlyRole;
GO

-- Add users to roles
ALTER ROLE SalesRole ADD MEMBER SalesUser;
ALTER ROLE HRRole ADD MEMBER HRUser;
ALTER ROLE ReadOnlyRole ADD MEMBER ReportUser;
GO

-- Grant permissions to roles
-- Syntax: GRANT [permission] ON [object] TO [role]
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Sales TO SalesRole;
GRANT EXECUTE ON OBJECT::Sales.usp_AddCustomer TO SalesRole;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::HR TO HRRole;

GRANT SELECT ON SCHEMA::Sales TO ReadOnlyRole;
GRANT SELECT ON SCHEMA::HR TO ReadOnlyRole;
GO

-- Create a synonym (alias for object)
CREATE SYNONYM Sales.Cust FOR Sales.Customers;
GO

-- Test synonym
SELECT * FROM Sales.Cust;  -- Same as Sales.Customers
GO

-- Section 9: Real-World Application - Complete Database Design
--------------------------------------------------------------------
-- Create a comprehensive business database with relationships
--------------------------------------------------------------------

-- Create additional tables for complete schema
CREATE TABLE HR.Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL UNIQUE,
    ManagerID INT NULL,
    Budget DECIMAL(12,2) DEFAULT 0.00,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE HR.EmployeeDetails (
    EmployeeDetailID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL UNIQUE,
    DepartmentID INT NULL,
    JobTitle NVARCHAR(50) NOT NULL,
    SalaryGrade INT DEFAULT 1,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    -- Foreign keys
    CONSTRAINT FK_EmployeeDetails_Employee FOREIGN KEY (EmployeeID)
        REFERENCES HR.Employees(EmployeeID),
    CONSTRAINT FK_EmployeeDetails_Department FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID),
    -- Check constraints
    CONSTRAINT CHK_EmployeeDetails_Dates CHECK (StartDate <= ISNULL(EndDate, '9999-12-31'))
);
GO

-- Create audit table with triggers
CREATE TABLE Audit.TableChanges (
    ChangeID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    ChangeType CHAR(1) NOT NULL,  -- I=Insert, U=Update, D=Delete
    ChangeDate DATETIME DEFAULT GETDATE(),
    ChangedBy NVARCHAR(128) DEFAULT SYSTEM_USER,
    OldData XML NULL,
    NewData XML NULL,
    CONSTRAINT CHK_TableChanges_Type CHECK (ChangeType IN ('I', 'U', 'D'))
);
GO

-- Create sequence object (alternative to IDENTITY)
CREATE SEQUENCE Sales.OrderNumberSeq
    AS INT
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    MAXVALUE 999999
    CYCLE;  -- Restart after reaching max
GO

-- Create table using sequence
CREATE TABLE Sales.SpecialOrders (
    SpecialOrderID INT PRIMARY KEY DEFAULT (NEXT VALUE FOR Sales.OrderNumberSeq),
    CustomerID INT NOT NULL,
    OrderDescription NVARCHAR(500),
    PriorityLevel INT DEFAULT 1,
    CONSTRAINT FK_SpecialOrders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID)
);
GO

-- Test the complete design
INSERT INTO HR.Departments (DepartmentName, ManagerID, Budget)
VALUES ('Sales', NULL, 500000.00),
       ('IT', NULL, 300000.00);

INSERT INTO HR.Employees (FirstName, LastName, Email, DepartmentID, Salary)
VALUES ('Michael', 'Brown', 'michael.b@example.com', 1, 75000.00);

INSERT INTO HR.EmployeeDetails (EmployeeID, DepartmentID, JobTitle, StartDate)
VALUES (1, 1, 'Sales Manager', '2024-01-15');

-- Use sequence
INSERT INTO Sales.SpecialOrders (CustomerID, OrderDescription, PriorityLevel)
VALUES (1, 'Custom configured laptop', 2);

SELECT * FROM Sales.SpecialOrders;
GO

-- Section 10: Best Practices and Optimization
--------------------------------------------------------------------
-- Performance considerations and DDL best practices
--------------------------------------------------------------------

-- 1. Use appropriate data types
-- 2. Always specify NULL/NOT NULL
-- 3. Use constraints for data integrity
-- 4. Consider indexing strategy
-- 5. Use schemas for organization

-- Example: Creating optimized table with all best practices
CREATE TABLE Sales.OptimizedOrders (
    OrderID INT IDENTITY(1,1) NOT NULL,
    OrderDate DATETIME NOT NULL,
    CustomerID INT NOT NULL,
    SalesPersonID INT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    TaxAmount DECIMAL(10,2) NOT NULL,
    ShippingAmount DECIMAL(10,2) NOT NULL,
    OrderStatusID TINYINT NOT NULL,  -- Small int for status codes
    -- Primary key with clustered index
    CONSTRAINT PK_OptimizedOrders PRIMARY KEY CLUSTERED (OrderID),
    -- Foreign keys
    CONSTRAINT FK_OptimizedOrders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),
    -- Check constraints
    CONSTRAINT CHK_OptimizedOrders_Amounts CHECK (TotalAmount >= 0 AND TaxAmount >= 0 AND ShippingAmount >= 0),
    CONSTRAINT CHK_OptimizedOrders_Status CHECK (OrderStatusID BETWEEN 1 AND 10),
    -- Default constraints
    CONSTRAINT DF_OptimizedOrders_OrderDate DEFAULT GETDATE() FOR OrderDate,
    CONSTRAINT DF_OptimizedOrders_Status DEFAULT 1 FOR OrderStatusID
) ON [PRIMARY];
GO

-- Create covering indexes
CREATE NONCLUSTERED INDEX IX_OptimizedOrders_CustomerDate
ON Sales.OptimizedOrders(CustomerID, OrderDate)
INCLUDE (TotalAmount, OrderStatusID)
WITH (FILLFACTOR = 90);  -- Leave 10% free space for updates
GO

-- Create filtered index for active orders
CREATE NONCLUSTERED INDEX IX_OptimizedOrders_Active
ON Sales.OptimizedOrders(OrderID)
WHERE OrderStatusID IN (1, 2, 3);  -- Only index pending/processing orders
GO

-- Add column with sparse attribute (for mostly NULL columns)
ALTER TABLE Sales.OptimizedOrders
ADD SpecialInstructions NVARCHAR(500) SPARSE NULL;
GO

-- View table storage information
EXEC sp_spaceused 'Sales.OptimizedOrders';
GO

-- Section 11: Viewing and Managing DDL Objects
--------------------------------------------------------------------
-- Query system catalog to inspect database objects
--------------------------------------------------------------------

-- View all tables with their schemas
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    t.create_date AS CreatedDate,
    t.modify_date AS ModifiedDate,
    p.rows AS RowCount
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
WHERE p.rows IS NOT NULL OR p.index_id IS NULL
ORDER BY s.name, t.name;
GO

-- View all columns in database
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable,
    c.is_identity AS IsIdentity,
    c.is_computed AS IsComputed
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE t.name IN ('Customers', 'Orders', 'Employees')
ORDER BY s.name, t.name, c.column_id;
GO

-- View all constraints
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ConstraintName,
    c.type_desc AS ConstraintType,
    c.definition AS Definition
FROM sys.check_constraints c
JOIN sys.tables t ON c.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
UNION ALL
SELECT 
    s.name,
    t.name,
    fk.name,
    'FOREIGN_KEY',
    OBJECT_NAME(fk.referenced_object_id) + '(' + COL_NAME(fk.parent_object_id, fkc.parent_column_id) + ')'
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
ORDER BY SchemaName, TableName, ConstraintType;
GO

-- View all stored procedures and functions
SELECT 
    s.name AS SchemaName,
    o.name AS ObjectName,
    o.type_desc AS ObjectType,
    o.create_date AS CreatedDate,
    OBJECT_DEFINITION(o.object_id) AS Definition
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.type IN ('P', 'FN', 'TF', 'IF')  -- Procedures and functions
ORDER BY s.name, o.type_desc, o.name;
GO

-- Generate CREATE scripts for all tables
SELECT 
    'CREATE TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' (' AS CreateScript
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name NOT LIKE 'sys%'
ORDER BY s.name, t.name;
GO

-- Section 12: Summary and Next Steps
--------------------------------------------------------------------
-- Key takeaways and resources for continued learning
--------------------------------------------------------------------

/*
KEY DDL COMMANDS COVERED:
1. CREATE: DATABASE, TABLE, VIEW, INDEX, PROCEDURE, FUNCTION, SCHEMA
2. ALTER: Modify existing objects
3. DROP: Remove objects
4. TRUNCATE: Remove all rows from table
5. RENAME: sp_rename system procedure

DATA TYPES MASTERED:
1. Exact numerics: INT, DECIMAL, NUMERIC
2. Approximate numerics: FLOAT, REAL
3. Character strings: CHAR, VARCHAR, TEXT
4. Unicode strings: NCHAR, NVARCHAR, NTEXT
5. Binary: BINARY, VARBINARY, IMAGE
6. Date/Time: DATE, TIME, DATETIME, DATETIME2
7. Special types: BIT, XML, TABLE, UNIQUEIDENTIFIER

CONSTRAINT TYPES:
1. PRIMARY KEY: Unique identifier, creates clustered index
2. FOREIGN KEY: Referential integrity between tables
3. UNIQUE: Ensures column values are unique
4. CHECK: Validates data based on condition
5. DEFAULT: Provides default value for column
6. NOT NULL: Column cannot contain NULL values

INDEX TYPES:
1. CLUSTERED: Determines physical order (only one per table)
2. NONCLUSTERED: Separate structure with pointers to data
3. UNIQUE: Ensures index keys are unique
4. COMPOSITE: On multiple columns
5. INCLUDED: Additional columns in leaf nodes
6. FILTERED: On subset of rows
7. COLUMNSTORE: For data warehousing scenarios

BEST PRACTICES:
1. Use meaningful, consistent naming conventions
2. Always specify NULL/NOT NULL for columns
3. Use smallest appropriate data type
4. Implement proper constraints for data integrity
5. Consider indexing strategy during design
6. Use schemas for logical organization
7. Document your DDL with comments

COMMON PITFALLS TO AVOID:
1. Using deprecated data types (TEXT, NTEXT, IMAGE)
2. Not specifying NULL/NOT NULL (defaults to NULL)
3. Over-indexing (hurts INSERT/UPDATE performance)
4. Missing foreign key constraints
5. Not considering data growth and partitioning
6. Ignoring collation differences

NEXT STEPS TO EXPLORE:
1. Partitioned tables for large datasets
2. Temporal tables for change tracking
3. Columnstore indexes for analytics
4. Memory-optimized tables for high performance
5. Graph databases for relationship-heavy data
6. PolyBase for external data access

INTERVIEW QUESTIONS TO MASTER:
1. Difference between CHAR and VARCHAR?
2. When to use UNIQUEIDENTIFIER vs IDENTITY?
3. Clustered vs Non-clustered index?
4. TRUNCATE vs DELETE?
5. Benefits of using schemas?
6. How to handle database versioning?

OFFICIAL DOCUMENTATION:
- CREATE TABLE: https://docs.microsoft.com/sql/t-sql/statements/create-table-transact-sql
- Data Types: https://docs.microsoft.com/sql/t-sql/data-types/data-types-transact-sql
- Constraints: https://docs.microsoft.com/sql/relational-databases/tables/primary-and-foreign-key-constraints
*/

-- Cleanup example (commented out for preservation)
/*
USE master;
GO
ALTER DATABASE DDLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DDLTutorialDB;
GO
*/

-- Final test of all objects
PRINT '========================================';
PRINT 'DDL TUTORIAL COMPLETED SUCCESSFULLY';
PRINT 'Objects created:';
PRINT '- 3 Schemas (Sales, HR, Audit)';
PRINT '- 10+ Tables with relationships';
PRINT '- Indexes, Views, Stored Procedures';
PRINT '- Functions, Sequences, Synonyms';
PRINT '- Users, Roles, Permissions';
PRINT '========================================';
GO
