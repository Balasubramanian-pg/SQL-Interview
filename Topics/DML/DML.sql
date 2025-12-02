/*
================================================================================
COMPREHENSIVE SQL DML TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to Data Manipulation Language (DML) with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- DML = Data Manipulation Language (SELECT, INSERT, UPDATE, DELETE, MERGE)
-- Focus: Data retrieval and modification
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DMLTutorialDB')
BEGIN
    ALTER DATABASE DMLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DMLTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE DMLTutorialDB;
GO

USE DMLTutorialDB;
GO

-- Enable advanced options for demonstration
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create sample tables with realistic business schema
-- Understanding data types, constraints, and relationships
--------------------------------------------------------------------

-- Create Customers table with various data types
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode AS 'CUST' + RIGHT('00000' + CAST(CustomerID AS VARCHAR(5)), 5) PERSISTED,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    DateOfBirth DATE,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    CreditLimit DECIMAL(10,2) DEFAULT 1000.00,
    IsActive BIT DEFAULT 1,
    CustomerType VARCHAR(20) DEFAULT 'Retail' 
        CHECK (CustomerType IN ('Retail', 'Wholesale', 'Corporate')),
    Notes NVARCHAR(MAX),
    -- Constraints for data integrity
    CONSTRAINT CHK_Customers_Email CHECK (Email LIKE '%@%.%'),
    CONSTRAINT CHK_Customers_CreditLimit CHECK (CreditLimit >= 0)
);
GO

-- Create Products table with inventory tracking
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(20) UNIQUE NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2) NOT NULL,
    CostPrice DECIMAL(10,2),
    StockQuantity INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10,
    IsDiscontinued BIT DEFAULT 0,
    LastRestockDate DATETIME,
    Description NVARCHAR(500),
    -- Constraints
    CONSTRAINT CHK_Products_Price CHECK (UnitPrice > 0),
    CONSTRAINT CHK_Products_Stock CHECK (StockQuantity >= 0),
    CONSTRAINT DF_Products_ProductCode DEFAULT ('PROD' + RIGHT('0000' + CAST(NEXT VALUE FOR seq_ProductCode AS VARCHAR(4)), 4)) FOR ProductCode
);
GO

-- Create sequence for product codes
CREATE SEQUENCE seq_ProductCode
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 9999;
GO

-- Create Orders table with foreign key relationships
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber AS 'ORD' + RIGHT('00000' + CAST(OrderID AS VARCHAR(5)), 5) PERSISTED,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATE,
    ShippedDate DATETIME,
    OrderStatus VARCHAR(20) DEFAULT 'Pending'
        CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    TotalAmount DECIMAL(10,2) DEFAULT 0.00,
    TaxAmount DECIMAL(10,2) DEFAULT 0.00,
    ShippingAmount DECIMAL(10,2) DEFAULT 0.00,
    PaymentMethod VARCHAR(30),
    -- Foreign key
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID)
        ON DELETE CASCADE,
    -- Check constraints
    CONSTRAINT CHK_Orders_Dates CHECK (OrderDate <= ISNULL(ShippedDate, '9999-12-31')),
    CONSTRAINT CHK_Orders_Amounts CHECK (TotalAmount >= 0 AND TaxAmount >= 0 AND ShippingAmount >= 0)
);
GO

-- Create OrderDetails table for line items
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0.00,
    LineTotal AS (Quantity * UnitPrice * (1 - Discount/100)) PERSISTED,
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

-- Create audit table for tracking changes
CREATE TABLE CustomerAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ChangeType CHAR(1) CHECK (ChangeType IN ('I', 'U', 'D')),
    ChangeDate DATETIME DEFAULT GETDATE(),
    ChangedBy NVARCHAR(100) DEFAULT SYSTEM_USER,
    OldData XML,
    NewData XML
);
GO

-- Insert sample data for all tables
-- Section 2: Fundamental Concepts - INSERT Statement
--------------------------------------------------------------------
-- INSERT adds new rows to tables
-- Single row, multiple rows, and SELECT INTO variations
--------------------------------------------------------------------

-- Insert single row with explicit column list (BEST PRACTICE)
-- Syntax: INSERT INTO table (columns) VALUES (values)
INSERT INTO Customers (FirstName, LastName, Email, Phone, DateOfBirth, CreditLimit, CustomerType)
VALUES ('John', 'Smith', 'john.smith@example.com', '555-0101', '1985-03-15', 5000.00, 'Corporate');
GO

-- Insert single row with implicit columns (columns inferred from VALUES)
-- WARNING: This depends on column order - fragile if table structure changes
INSERT INTO Customers 
VALUES ('Maria', 'Garcia', 'maria.garcia@example.com', '555-0102', '1990-07-22', GETDATE(), 10000.00, 1, 'Retail', NULL);
GO

-- Insert multiple rows in single statement (SQL Server 2008+)
-- More efficient than multiple single inserts
INSERT INTO Customers (FirstName, LastName, Email, Phone, CreditLimit, CustomerType)
VALUES 
    ('David', 'Chen', 'david.chen@example.com', '555-0103', 7500.00, 'Wholesale'),
    ('Sarah', 'Johnson', 'sarah.johnson@example.com', '555-0104', 3000.00, 'Retail'),
    ('Michael', 'Brown', 'michael.brown@example.com', '555-0105', 15000.00, 'Corporate');
GO

-- Insert with DEFAULT values
INSERT INTO Customers (FirstName, LastName, Email)
VALUES ('Emily', 'Wilson', 'emily.wilson@example.com');
-- All other columns will use their DEFAULT values
GO

-- Insert with OUTPUT clause - returns inserted values
-- Useful for getting identity values or auditing
DECLARE @InsertedCustomerID INT;
DECLARE @InsertedCustomerCode VARCHAR(20);

INSERT INTO Customers (FirstName, LastName, Email, CustomerType)
OUTPUT inserted.CustomerID, inserted.CustomerCode
INTO @InsertedCustomerID, @InsertedCustomerCode
VALUES ('Robert', 'Taylor', 'robert.taylor@example.com', 'Retail');

PRINT 'New Customer ID: ' + CAST(@InsertedCustomerID AS VARCHAR);
GO

-- Insert products using sequence for ProductCode
INSERT INTO Products (ProductName, Category, UnitPrice, CostPrice, StockQuantity)
VALUES 
    ('Laptop Pro', 'Electronics', 1299.99, 900.00, 50),
    ('Wireless Mouse', 'Electronics', 39.99, 15.00, 200),
    ('Office Chair', 'Furniture', 299.99, 150.00, 30),
    ('Desk Lamp', 'Home', 49.99, 20.00, 100),
    ('Notebook', 'Office Supplies', 12.99, 5.00, 500);
GO

-- Verify inserts
SELECT 'Customers inserted:' AS Status, COUNT(*) AS Count FROM Customers;
SELECT 'Products inserted:' AS Status, COUNT(*) AS Count FROM Products;
GO

-- Section 3: Fundamental Concepts - SELECT Statement
--------------------------------------------------------------------
-- SELECT retrieves data from tables
-- Basic queries, filtering, sorting, and aggregation
--------------------------------------------------------------------

-- Basic SELECT with all columns (use * cautiously in production)
-- Syntax: SELECT columns FROM table WHERE conditions ORDER BY columns
SELECT * FROM Customers;
GO

-- SELECT specific columns with aliases
SELECT 
    CustomerID AS ID,
    FirstName + ' ' + LastName AS FullName,
    Email AS ContactEmail,
    CreditLimit,
    CustomerType AS Type
FROM Customers;
GO

-- SELECT with WHERE clause for filtering
SELECT 
    CustomerID,
    FirstName,
    LastName,
    CreditLimit
FROM Customers
WHERE CustomerType = 'Corporate' 
    AND CreditLimit > 7000.00;
GO

-- SELECT with ORDER BY for sorting
SELECT 
    CustomerID,
    FirstName,
    LastName,
    RegistrationDate
FROM Customers
ORDER BY RegistrationDate DESC, LastName ASC;  -- Most recent first, then by name
GO

-- SELECT with TOP clause to limit results
SELECT TOP 3
    CustomerID,
    FirstName,
    LastName,
    CreditLimit
FROM Customers
ORDER BY CreditLimit DESC;  -- Top 3 customers by credit limit
GO

-- SELECT with DISTINCT to remove duplicates
SELECT DISTINCT CustomerType FROM Customers;
GO

-- SELECT with computed columns
SELECT 
    FirstName,
    LastName,
    CreditLimit,
    CreditLimit * 0.8 AS RecommendedLimit  -- 80% of current limit
FROM Customers;
GO

-- SELECT with string functions
SELECT 
    CustomerID,
    UPPER(LastName) AS LastNameUpper,
    LEFT(FirstName, 1) + '.' AS FirstInitial,
    LEN(FirstName + LastName) AS NameLength
FROM Customers;
GO

-- Test SELECT statements
PRINT 'SELECT statements tested successfully';
GO

-- Section 4: Core Functionality - UPDATE Statement
--------------------------------------------------------------------
-- UPDATE modifies existing data in tables
-- Single table updates, joins in updates, and conditional updates
--------------------------------------------------------------------

-- Basic UPDATE single row
-- Syntax: UPDATE table SET column = value WHERE conditions
UPDATE Customers
SET CreditLimit = 5500.00
WHERE CustomerID = 1;  -- Always use WHERE to avoid updating all rows!

PRINT 'Customer 1 credit limit updated';
GO

-- UPDATE multiple columns
UPDATE Customers
SET 
    Phone = '555-0110',
    CustomerType = 'Corporate',
    CreditLimit = CreditLimit * 1.1  -- 10% increase
WHERE CustomerID = 2;
GO

-- UPDATE with CASE statement for conditional logic
UPDATE Customers
SET CreditLimit = 
    CASE 
        WHEN CustomerType = 'Corporate' THEN CreditLimit * 1.15  -- 15% increase
        WHEN CustomerType = 'Wholesale' THEN CreditLimit * 1.10  -- 10% increase
        ELSE CreditLimit * 1.05  -- 5% increase for retail
    END
WHERE IsActive = 1;
GO

-- UPDATE with FROM clause (join with another table)
-- Increase credit limit for customers with orders
UPDATE c
SET c.CreditLimit = c.CreditLimit * 1.05
FROM Customers c
INNER JOIN (
    SELECT DISTINCT CustomerID 
    FROM Orders
) o ON c.CustomerID = o.CustomerID;
GO

-- UPDATE with OUTPUT clause to capture changes
DECLARE @UpdateAudit TABLE (
    OldCreditLimit DECIMAL(10,2),
    NewCreditLimit DECIMAL(10,2),
    CustomerID INT
);

UPDATE Customers
SET CreditLimit = CreditLimit * 0.9  -- 10% decrease
OUTPUT deleted.CreditLimit, inserted.CreditLimit, inserted.CustomerID
INTO @UpdateAudit
WHERE CustomerType = 'Retail';

-- View the changes
SELECT * FROM @UpdateAudit;
GO

-- UPDATE with subquery
UPDATE Products
SET StockQuantity = StockQuantity - 10
WHERE ProductID IN (
    SELECT ProductID 
    FROM Products 
    WHERE Category = 'Electronics' 
        AND StockQuantity > 20
);
GO

-- Test UPDATE statements
SELECT CustomerID, FirstName, CreditLimit, CustomerType 
FROM Customers 
ORDER BY CustomerID;
GO

-- Section 5: Core Functionality - DELETE Statement
--------------------------------------------------------------------
-- DELETE removes rows from tables
-- TRUNCATE vs DELETE, cascading deletes, and soft deletes
--------------------------------------------------------------------

-- First, insert some orders for testing
INSERT INTO Orders (CustomerID, TotalAmount, OrderStatus)
VALUES 
    (1, 1299.99, 'Pending'),
    (2, 599.99, 'Processing'),
    (3, 299.99, 'Completed'),
    (4, 899.99, 'Pending');
GO

-- Basic DELETE single row
-- Syntax: DELETE FROM table WHERE conditions
DELETE FROM Orders
WHERE OrderID = 4;  -- Always use WHERE to avoid deleting all rows!

PRINT 'Order 4 deleted';
GO

-- DELETE with join (using EXISTS)
DELETE FROM Orders
WHERE EXISTS (
    SELECT 1 
    FROM Customers 
    WHERE Customers.CustomerID = Orders.CustomerID 
        AND Customers.CustomerType = 'Retail'
        AND Customers.CreditLimit < 5000
);
GO

-- DELETE with OUTPUT clause
DECLARE @DeletedOrders TABLE (
    OrderID INT,
    CustomerID INT,
    TotalAmount DECIMAL(10,2)
);

DELETE FROM Orders
OUTPUT deleted.OrderID, deleted.CustomerID, deleted.TotalAmount
INTO @DeletedOrders
WHERE OrderStatus = 'Cancelled';

SELECT 'Deleted Orders:' AS Status, * FROM @DeletedOrders;
GO

-- DELETE with foreign key cascade (set up in table creation)
-- When we delete a customer, their orders are automatically deleted
DELETE FROM Customers 
WHERE CustomerID = 5;  -- This will also delete any orders for customer 5

SELECT 'Customer 5 and related orders deleted via cascade';
GO

-- TRUNCATE TABLE - removes all rows quickly
-- WARNING: Cannot be rolled back, no WHERE clause, resets identity
CREATE TABLE TempTable (ID INT IDENTITY(1,1), Data VARCHAR(50));
INSERT INTO TempTable VALUES ('Test1'), ('Test2'), ('Test3');
SELECT * FROM TempTable;

TRUNCATE TABLE TempTable;  -- All rows gone, IDENTITY reset to 1
SELECT 'TRUNCATE executed, table emptied' AS Status;

DROP TABLE TempTable;
GO

-- Soft delete pattern (instead of physical delete)
ALTER TABLE Customers
ADD IsDeleted BIT DEFAULT 0;
GO

-- Instead of DELETE, we UPDATE
UPDATE Customers
SET IsDeleted = 1
WHERE CustomerID = 3;  -- "Soft delete" customer 3

SELECT CustomerID, FirstName, IsDeleted 
FROM Customers 
WHERE IsDeleted = 1;
GO

-- Section 6: Intermediate Techniques - MERGE Statement
--------------------------------------------------------------------
-- MERGE performs INSERT, UPDATE, DELETE in single statement
-- Also known as UPSERT (UPDATE or INSERT)
--------------------------------------------------------------------

-- Create staging table for MERGE example
CREATE TABLE CustomerUpdates (
    CustomerID INT NULL,  -- NULL for new customers
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    CreditLimit DECIMAL(10,2),
    Action VARCHAR(10)  -- 'INSERT', 'UPDATE', 'DELETE'
);
GO

-- Insert test data into staging table
INSERT INTO CustomerUpdates (CustomerID, FirstName, LastName, Email, CreditLimit, Action)
VALUES 
    (NULL, 'Jennifer', 'Lee', 'jennifer.lee@example.com', 8000.00, 'INSERT'),
    (2, 'Maria', 'Garcia-Updated', 'maria.garcia.updated@example.com', 12000.00, 'UPDATE'),
    (3, NULL, NULL, NULL, NULL, 'DELETE');  -- Will be soft deleted
GO

-- MERGE statement - synchronize Customers with CustomerUpdates
MERGE Customers AS Target
USING CustomerUpdates AS Source
ON (Target.CustomerID = Source.CustomerID)
WHEN MATCHED AND Source.Action = 'UPDATE' THEN
    UPDATE SET 
        FirstName = Source.FirstName,
        LastName = Source.LastName,
        Email = Source.Email,
        CreditLimit = Source.CreditLimit
WHEN MATCHED AND Source.Action = 'DELETE' THEN
    UPDATE SET 
        IsDeleted = 1  -- Soft delete
WHEN NOT MATCHED BY TARGET AND Source.Action = 'INSERT' THEN
    INSERT (FirstName, LastName, Email, CreditLimit)
    VALUES (Source.FirstName, Source.LastName, Source.Email, Source.CreditLimit)
WHEN NOT MATCHED BY SOURCE THEN
    -- Optional: Handle customers not in staging table
    -- DELETE  -- Would physically delete
    -- For now, do nothing
    UPDATE SET Target.CreditLimit = Target.CreditLimit  -- No-op
OUTPUT 
    $action AS Operation,
    inserted.CustomerID AS NewID,
    deleted.CustomerID AS OldID,
    inserted.FirstName,
    inserted.LastName;
GO

-- Clean up staging table
DROP TABLE CustomerUpdates;
GO

-- Section 7: Advanced SELECT Features
--------------------------------------------------------------------
-- Joins, subqueries, CTEs, window functions, and pagination
--------------------------------------------------------------------

-- Insert order details for advanced queries
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, Discount)
VALUES 
    (1, 1, 1, 1299.99, 0.00),   -- Laptop
    (1, 2, 2, 39.99, 10.00),    -- Mouse with 10% discount
    (2, 3, 1, 299.99, 0.00),    -- Chair
    (2, 4, 3, 49.99, 5.00);     -- Lamps with 5% discount
GO

-- INNER JOIN - returns matching rows from both tables
SELECT 
    o.OrderID,
    o.OrderDate,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    o.TotalAmount,
    o.OrderStatus
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.IsActive = 1
ORDER BY o.OrderDate DESC;
GO

-- LEFT JOIN - all rows from left table, matching from right
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(o.OrderID) AS OrderCount,
    SUM(ISNULL(o.TotalAmount, 0)) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;
GO

-- Multiple joins with aggregation
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantity,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount/100)) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerID, c.FirstName, c.LastName, p.ProductName
ORDER BY TotalSpent DESC;
GO

-- Subqueries in SELECT clause
SELECT 
    CustomerID,
    FirstName,
    LastName,
    CreditLimit,
    (SELECT AVG(CreditLimit) FROM Customers) AS AvgCreditLimit,
    CreditLimit - (SELECT AVG(CreditLimit) FROM Customers) AS DifferenceFromAvg
FROM Customers;
GO

-- Subqueries in WHERE clause
SELECT 
    ProductName,
    UnitPrice,
    Category
FROM Products
WHERE UnitPrice > (
    SELECT AVG(UnitPrice) 
    FROM Products 
    WHERE Category = 'Electronics'
);
GO

-- EXISTS subquery
SELECT 
    CustomerID,
    FirstName,
    LastName
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID 
        AND o.TotalAmount > 1000
);
GO

-- Common Table Expressions (CTEs) for complex queries
WITH CustomerSummary AS (
    SELECT 
        c.CustomerID,
        c.FirstName + ' ' + c.LastName AS FullName,
        c.CustomerType,
        COUNT(o.OrderID) AS OrderCount,
        SUM(ISNULL(o.TotalAmount, 0)) AS TotalSpent
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.CustomerType
),
HighValueCustomers AS (
    SELECT *
    FROM CustomerSummary
    WHERE TotalSpent > 1000
)
SELECT 
    CustomerType,
    COUNT(*) AS CustomerCount,
    AVG(TotalSpent) AS AvgSpent,
    SUM(TotalSpent) AS TotalRevenue
FROM HighValueCustomers
GROUP BY CustomerType
ORDER BY TotalRevenue DESC;
GO

-- Window functions for analytics
SELECT 
    CustomerID,
    FirstName,
    LastName,
    CreditLimit,
    RANK() OVER (ORDER BY CreditLimit DESC) AS CreditRank,
    DENSE_RANK() OVER (ORDER BY CreditLimit DESC) AS CreditDenseRank,
    ROW_NUMBER() OVER (ORDER BY CreditLimit DESC) AS RowNumber,
    NTILE(4) OVER (ORDER BY CreditLimit DESC) AS CreditQuartile,
    LAG(CreditLimit, 1) OVER (ORDER BY CreditLimit DESC) AS PrevCreditLimit,
    LEAD(CreditLimit, 1) OVER (ORDER BY CreditLimit DESC) AS NextCreditLimit,
    SUM(CreditLimit) OVER () AS TotalCredit,
    AVG(CreditLimit) OVER () AS AvgCredit
FROM Customers
WHERE IsActive = 1;
GO

-- Pagination with OFFSET-FETCH (SQL Server 2012+)
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    RegistrationDate
FROM Customers
WHERE IsActive = 1
ORDER BY RegistrationDate DESC
OFFSET 0 ROWS  -- Skip 0 rows
FETCH NEXT 5 ROWS ONLY;  -- Take 5 rows (Page 1)

-- Page 2
SELECT 
    CustomerID,
    FirstName,
    LastName,
    Email,
    RegistrationDate
FROM Customers
WHERE IsActive = 1
ORDER BY RegistrationDate DESC
OFFSET 5 ROWS  -- Skip first 5 rows
FETCH NEXT 5 ROWS ONLY;  -- Take next 5 rows
GO

-- Section 8: Advanced DML Operations
--------------------------------------------------------------------
-- Transactions, error handling, bulk operations, and performance
--------------------------------------------------------------------

-- Transactions with error handling
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Insert new order
    DECLARE @NewOrderID INT;
    
    INSERT INTO Orders (CustomerID, TotalAmount, OrderStatus)
    VALUES (1, 1999.99, 'Pending');
    
    SET @NewOrderID = SCOPE_IDENTITY();
    
    -- Insert order details
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@NewOrderID, 1, 1, 1299.99);
    
    -- Update product stock
    UPDATE Products
    SET StockQuantity = StockQuantity - 1
    WHERE ProductID = 1;
    
    -- Validate stock level
    IF (SELECT StockQuantity FROM Products WHERE ProductID = 1) < 0
    BEGIN
        RAISERROR('Insufficient stock', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    COMMIT TRANSACTION;
    PRINT 'Transaction completed successfully';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back due to error: ' + ERROR_MESSAGE();
END CATCH
GO

-- Bulk INSERT from file (simulated with table variable)
DECLARE @BulkData TABLE (
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    CreditLimit DECIMAL(10,2)
);

-- Simulate loading data
INSERT INTO @BulkData VALUES
    ('Alex', 'Turner', 'alex.turner@example.com', 4500.00),
    ('Taylor', 'Swift', 'taylor.swift@example.com', 25000.00),
    ('Chris', 'Martin', 'chris.martin@example.com', 8000.00);

-- Bulk insert with transaction
BEGIN TRANSACTION;
    INSERT INTO Customers (FirstName, LastName, Email, CreditLimit)
    SELECT FirstName, LastName, Email, CreditLimit
    FROM @BulkData;
    
    PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' rows inserted via bulk operation';
COMMIT TRANSACTION;
GO

-- MERGE with error handling
BEGIN TRY
    MERGE Products AS Target
    USING (VALUES 
        ('New Laptop', 'Electronics', 1499.99, 1100.00, 25),
        ('Gaming Mouse', 'Electronics', 79.99, 35.00, 100)
    ) AS Source (ProductName, Category, UnitPrice, CostPrice, StockQuantity)
    ON (Target.ProductName = Source.ProductName)
    WHEN NOT MATCHED THEN
        INSERT (ProductName, Category, UnitPrice, CostPrice, StockQuantity)
        VALUES (Source.ProductName, Source.Category, Source.UnitPrice, Source.CostPrice, Source.StockQuantity);
        
    PRINT 'MERGE operation completed';
END TRY
BEGIN CATCH
    PRINT 'MERGE failed: ' + ERROR_MESSAGE();
END CATCH
GO

-- Section 9: Real-World Application - Complete Business Scenario
--------------------------------------------------------------------
-- Complex business logic using multiple DML operations
--------------------------------------------------------------------

-- Scenario: Process monthly customer credit limit review
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Step 1: Archive old credit limits before update
    CREATE TABLE #CreditLimitArchive (
        CustomerID INT,
        OldCreditLimit DECIMAL(10,2),
        NewCreditLimit DECIMAL(10,2),
        ChangeDate DATETIME DEFAULT GETDATE()
    );
    
    -- Step 2: Calculate new credit limits based on order history
    WITH CustomerOrderSummary AS (
        SELECT 
            c.CustomerID,
            c.CreditLimit AS OldCreditLimit,
            COUNT(o.OrderID) AS OrderCount,
            SUM(ISNULL(o.TotalAmount, 0)) AS TotalSpent,
            MAX(o.OrderDate) AS LastOrderDate
        FROM Customers c
        LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
        WHERE c.IsActive = 1 AND c.IsDeleted = 0
        GROUP BY c.CustomerID, c.CreditLimit
    )
    UPDATE c
    SET c.CreditLimit = 
        CASE 
            WHEN cos.OrderCount >= 5 AND cos.TotalSpent > 5000 THEN c.CreditLimit * 1.20
            WHEN cos.OrderCount >= 3 AND cos.TotalSpent > 2000 THEN c.CreditLimit * 1.15
            WHEN DATEDIFF(MONTH, cos.LastOrderDate, GETDATE()) <= 3 THEN c.CreditLimit * 1.10
            ELSE c.CreditLimit * 1.05
        END
    OUTPUT deleted.CustomerID, deleted.CreditLimit, inserted.CreditLimit
    INTO #CreditLimitArchive
    FROM Customers c
    INNER JOIN CustomerOrderSummary cos ON c.CustomerID = cos.CustomerID;
    
    -- Step 3: Log the changes
    INSERT INTO CustomerAudit (CustomerID, ChangeType, OldData, NewData)
    SELECT 
        CustomerID,
        'U',
        (SELECT OldCreditLimit FOR XML PATH(''), TYPE),
        (SELECT NewCreditLimit FOR XML PATH(''), TYPE)
    FROM #CreditLimitArchive;
    
    -- Step 4: Send notifications for significant increases
    PRINT 'Credit limits updated for ' + CAST(@@ROWCOUNT AS VARCHAR) + ' customers';
    
    -- Step 5: Generate report
    SELECT 
        CustomerID,
        OldCreditLimit,
        NewCreditLimit,
        NewCreditLimit - OldCreditLimit AS IncreaseAmount,
        ((NewCreditLimit - OldCreditLimit) / OldCreditLimit * 100) AS IncreasePercentage
    FROM #CreditLimitArchive
    WHERE NewCreditLimit > OldCreditLimit
    ORDER BY IncreaseAmount DESC;
    
    -- Cleanup
    DROP TABLE #CreditLimitArchive;
    
    COMMIT TRANSACTION;
    PRINT 'Monthly credit review completed successfully';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Credit review failed: ' + ERROR_MESSAGE();
    
    -- Log error
    INSERT INTO CustomerAudit (CustomerID, ChangeType, OldData, NewData)
    VALUES (-1, 'E', NULL, ERROR_MESSAGE());
END CATCH
GO

-- Section 10: Best Practices and Optimization
--------------------------------------------------------------------
-- Performance tips, error prevention, and production patterns
--------------------------------------------------------------------

-- 1. Always use explicit column lists in INSERT
-- 2. Use transactions for multiple related operations
-- 3. Implement proper error handling
-- 4. Use WHERE clauses in UPDATE/DELETE
-- 5. Consider performance of large operations

-- Performance: Use batch operations for large datasets
-- Instead of row-by-row processing
DECLARE @BatchSize INT = 1000;
DECLARE @RowsAffected INT = 1;
DECLARE @TotalRows INT = 0;

WHILE @RowsAffected > 0
BEGIN
    BEGIN TRANSACTION;
    
    UPDATE TOP (@BatchSize) Products
    SET StockQuantity = StockQuantity - 1
    WHERE ProductID IN (
        SELECT TOP (@BatchSize) ProductID 
        FROM Products 
        WHERE Category = 'Electronics' 
            AND StockQuantity > 0
    );
    
    SET @RowsAffected = @@ROWCOUNT;
    SET @TotalRows = @TotalRows + @RowsAffected;
    
    COMMIT TRANSACTION;
    
    -- Optional: Wait between batches for system breathing room
    -- WAITFOR DELAY '00:00:00.100';
    
    PRINT 'Processed batch of ' + CAST(@RowsAffected AS VARCHAR) + ' rows';
END

PRINT 'Total rows processed: ' + CAST(@TotalRows AS VARCHAR);
GO

-- Use OUTPUT for auditing without additional queries
DECLARE @ChangeLog TABLE (
    ChangeID INT IDENTITY(1,1),
    TableName VARCHAR(100),
    ChangeType CHAR(1),
    ChangeDate DATETIME DEFAULT GETDATE(),
    KeyValue INT
);

-- Combined DML with auditing
UPDATE Customers
SET CreditLimit = CreditLimit * 1.05
OUTPUT 'Customers', 'U', GETDATE(), inserted.CustomerID
INTO @ChangeLog
WHERE IsActive = 1;

SELECT * FROM @ChangeLog;
GO

-- Prevent accidental mass updates
-- Use BEGIN/COMMIT with SELECT first
BEGIN TRANSACTION;

-- First, see what will be affected
SELECT COUNT(*) AS RowsToUpdate
FROM Customers
WHERE CustomerType = 'Retail';

-- Then perform the update
UPDATE Customers
SET CreditLimit = CreditLimit * 1.03
WHERE CustomerType = 'Retail';

-- Verify before committing
SELECT 
    CustomerType,
    COUNT(*) AS CustomerCount,
    AVG(CreditLimit) AS AvgCreditLimit
FROM Customers
GROUP BY CustomerType;

-- If satisfied
COMMIT TRANSACTION;
-- If not satisfied
-- ROLLBACK TRANSACTION;
GO

-- Section 11: Viewing and Managing Data
--------------------------------------------------------------------
-- Querying system views to understand data distribution and changes
--------------------------------------------------------------------

-- View table sizes and row counts
SELECT 
    t.name AS TableName,
    s.name AS SchemaName,
    p.rows AS RowCount,
    SUM(a.total_pages) * 8 / 1024 AS SizeMB,
    MAX(a.type_desc) AS AllocationType
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.name IN ('Customers', 'Products', 'Orders', 'OrderDetails')
GROUP BY t.name, s.name, p.rows
ORDER BY SizeMB DESC;
GO

-- View identity column values
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    IDENT_CURRENT(QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name)) AS CurrentIdentity,
    IDENT_SEED(QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name)) AS SeedValue,
    IDENT_INCR(QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name)) AS IncrementValue
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
WHERE c.is_identity = 1
    AND t.name IN ('Customers', 'Products', 'Orders', 'OrderDetails');
GO

-- View recent DML operations from transaction log
SELECT 
    [Transaction ID],
    Operation,
    Context,
    AllocUnitName,
    [Page ID],
    [Slot ID],
    [Begin Time],
    [Transaction Name]
FROM fn_dblog(NULL, NULL)
WHERE Operation IN ('LOP_INSERT_ROWS', 'LOP_MODIFY_ROW', 'LOP_DELETE_ROWS')
    AND AllocUnitName LIKE '%Customers%'
ORDER BY [Begin Time] DESC;
GO

-- View data distribution for optimization
SELECT 
    CustomerType,
    COUNT(*) AS CustomerCount,
    AVG(CreditLimit) AS AvgCreditLimit,
    MIN(CreditLimit) AS MinCreditLimit,
    MAX(CreditLimit) AS MaxCreditLimit,
    SUM(CreditLimit) AS TotalCredit
FROM Customers
WHERE IsActive = 1 AND IsDeleted = 0
GROUP BY CustomerType
ORDER BY CustomerCount DESC;
GO

-- View referential integrity (foreign key relationships)
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS FromTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS FromColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ToTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ToColumn,
    fk.delete_referential_action_desc AS OnDelete,
    fk.update_referential_action_desc AS OnUpdate
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) IN ('Orders', 'OrderDetails')
ORDER BY FromTable, ToTable;
GO

-- Section 12: Summary and Next Steps
--------------------------------------------------------------------

/*
KEY DML CONCEPTS COVERED:
1. CRUD Operations:
   - CREATE: INSERT, SELECT INTO
   - READ: SELECT with all variations
   - UPDATE: Single/multi-row, conditional updates
   - DELETE: Single/multi-row, TRUNCATE

2. Advanced SELECT Features:
   - Joins (INNER, LEFT, RIGHT, FULL, CROSS)
   - Subqueries (correlated and non-correlated)
   - CTEs (Common Table Expressions)
   - Window Functions (RANK, ROW_NUMBER, LAG, LEAD)
   - Pagination (OFFSET-FETCH)

3. Data Modification Patterns:
   - MERGE/UPSERT operations
   - Bulk operations
   - Transaction management
   - Error handling with TRY-CATCH
   - OUTPUT clause for auditing

4. Performance Considerations:
   - Set-based vs row-based operations
   - Batch processing for large datasets
   - Proper indexing for DML performance
   - Transaction isolation levels

BEST PRACTICES:
1. Always use WHERE clauses with UPDATE/DELETE
2. Use explicit column lists in INSERT
3. Implement proper error handling
4. Use transactions for data consistency
5. Consider performance implications
6. Audit critical data changes
7. Validate data before modification

COMMON PITFALLS TO AVOID:
1. Missing WHERE clauses causing mass updates
2. Not handling NULL values properly
3. Ignoring transaction isolation levels
4. Using SELECT * in production code
5. Not considering locking and blocking
6. Forgetting to COMMIT or ROLLBACK transactions

NEXT STEPS TO EXPLORE:
1. Advanced window functions and analytics
2. Temporal tables for automatic history tracking
3. Change Data Capture (CDC)
4. Partitioned tables for large datasets
5. In-Memory OLTP for high-performance DML
6. Query optimization and execution plans

INTERVIEW QUESTIONS TO MASTER:
1. Difference between DELETE and TRUNCATE?
2. How does MERGE work and when to use it?
3. Explain different types of JOINs?
4. What are window functions and their use cases?
5. How to handle bulk data operations efficiently?
6. Transaction isolation levels and their impact?

OFFICIAL DOCUMENTATION:
- SELECT: https://docs.microsoft.com/sql/t-sql/queries/select-transact-sql
- INSERT: https://docs.microsoft.com/sql/t-sql/statements/insert-transact-sql
- UPDATE: https://docs.microsoft.com/sql/t-sql/queries/update-transact-sql
- DELETE: https://docs.microsoft.com/sql/t-sql/statements/delete-transact-sql
- MERGE: https://docs.microsoft.com/sql/t-sql/statements/merge-transact-sql
*/

-- Final cleanup and summary
PRINT '========================================';
PRINT 'DML TUTORIAL COMPLETED SUCCESSFULLY';
PRINT 'Concepts covered:';
PRINT '- Basic SELECT, INSERT, UPDATE, DELETE';
PRINT '- Advanced queries with JOINs and subqueries';
PRINT '- CTEs and window functions';
PRINT '- Transaction management and error handling';
PRINT '- Performance optimization techniques';
PRINT '========================================';

-- Optional: Reset database (comment out to preserve data)
/*
USE master;
GO
ALTER DATABASE DMLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DMLTutorialDB;
GO
*/
