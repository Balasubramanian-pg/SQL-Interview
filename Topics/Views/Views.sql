/*
================================================================================
COMPREHENSIVE SQL VIEWS TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to SQL Views with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- Views = Virtual tables based on SELECT queries
-- Focus: Security, abstraction, simplification, and performance
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ViewsTutorialDB')
BEGIN
    ALTER DATABASE ViewsTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ViewsTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE ViewsTutorialDB;
GO

USE ViewsTutorialDB;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create comprehensive sample schema for view demonstrations
-- Multiple tables with relationships for complex view scenarios
--------------------------------------------------------------------

-- Create Departments table
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    Budget DECIMAL(15,2) DEFAULT 0.00,
    Location NVARCHAR(100),
    EstablishedDate DATE DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- Create Employees table with sensitive and non-sensitive data
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    HireDate DATE NOT NULL,
    JobTitle NVARCHAR(50),
    Salary DECIMAL(10,2) NOT NULL,
    CommissionPct DECIMAL(5,2) DEFAULT 0.00,
    ManagerID INT NULL,
    DepartmentID INT NULL,
    SSN CHAR(9),  -- Sensitive data
    BirthDate DATE,  -- Sensitive data
    EmergencyContact NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    -- Computed columns
    FullName AS (FirstName + ' ' + LastName) PERSISTED,
    YearsOfService AS (DATEDIFF(YEAR, HireDate, GETDATE())) PERSISTED,
    -- Foreign keys
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID),
    -- Check constraints
    CONSTRAINT CHK_Employees_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Employees_Commission CHECK (CommissionPct BETWEEN 0 AND 100),
    CONSTRAINT CHK_Employees_SSN CHECK (LEN(SSN) = 9 OR SSN IS NULL)
);
GO

-- Create self-referencing foreign key for ManagerID
ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID)
    REFERENCES Employees(EmployeeID);
GO

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode AS ('CUST' + RIGHT('0000' + CAST(CustomerID AS VARCHAR(4)), 4)) PERSISTED,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    Address NVARCHAR(200),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode VARCHAR(20),
    Country NVARCHAR(50) DEFAULT 'USA',
    Phone VARCHAR(20),
    Email NVARCHAR(100),
    CustomerType VARCHAR(20) DEFAULT 'Retail'
        CHECK (CustomerType IN ('Retail', 'Wholesale', 'Corporate', 'Government')),
    CreditLimit DECIMAL(15,2) DEFAULT 5000.00,
    CustomerSince DATE DEFAULT GETDATE(),
    TaxID VARCHAR(20),  -- Sensitive data
    PaymentTerms VARCHAR(50),
    IsActive BIT DEFAULT 1
);
GO

-- Create Products table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode AS ('PROD' + RIGHT('0000' + CAST(ProductID AS VARCHAR(4)), 4)) PERSISTED,
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    SubCategory NVARCHAR(50),
    UnitPrice DECIMAL(10,2) NOT NULL,
    CostPrice DECIMAL(10,2) NOT NULL,
    QuantityInStock INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10,
    DiscontinuedDate DATE NULL,
    SupplierID INT,
    IsActive BIT DEFAULT 1,
    -- Check constraints
    CONSTRAINT CHK_Products_Price CHECK (UnitPrice > 0 AND CostPrice > 0),
    CONSTRAINT CHK_Products_Stock CHECK (QuantityInStock >= 0)
);
GO

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber AS ('ORD' + RIGHT('00000' + CAST(OrderID AS VARCHAR(5)), 5)) PERSISTED,
    CustomerID INT NOT NULL,
    EmployeeID INT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATE NULL,
    ShippedDate DATETIME NULL,
    ShipVia VARCHAR(50),
    Freight DECIMAL(10,2) DEFAULT 0.00,
    ShipAddress NVARCHAR(200),
    ShipCity NVARCHAR(50),
    ShipRegion NVARCHAR(50),
    ShipPostalCode VARCHAR(20),
    ShipCountry NVARCHAR(50),
    OrderStatus VARCHAR(20) DEFAULT 'Pending'
        CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'On Hold')),
    PaymentMethod VARCHAR(30),
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid',
    -- Foreign keys
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Orders_Employees FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID),
    -- Check constraints
    CONSTRAINT CHK_Orders_Dates CHECK (OrderDate <= ISNULL(ShippedDate, '9999-12-31')),
    CONSTRAINT CHK_Orders_Freight CHECK (Freight >= 0)
);
GO

-- Create OrderDetails table
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

-- Create indexes for performance
CREATE INDEX IX_Employees_DepartmentID ON Employees(DepartmentID);
CREATE INDEX IX_Employees_ManagerID ON Employees(ManagerID);
CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX IX_Orders_EmployeeID ON Orders(EmployeeID);
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX IX_Products_Category ON Products(Category);
CREATE INDEX IX_Customers_Country ON Customers(Country);
GO

-- Insert sample data
INSERT INTO Departments (DepartmentName, Location, Budget)
VALUES 
    ('Sales', 'New York', 500000.00),
    ('Marketing', 'Chicago', 300000.00),
    ('IT', 'San Francisco', 800000.00),
    ('Finance', 'Boston', 400000.00),
    ('HR', 'Austin', 200000.00);
GO

INSERT INTO Employees (FirstName, LastName, Email, Phone, HireDate, JobTitle, Salary, DepartmentID, SSN, BirthDate)
VALUES 
    ('John', 'Smith', 'john.smith@company.com', '555-0101', '2020-03-15', 'Sales Manager', 85000.00, 1, '123456789', '1985-03-15'),
    ('Maria', 'Garcia', 'maria.garcia@company.com', '555-0102', '2021-06-01', 'Sales Representative', 65000.00, 1, '987654321', '1990-07-22'),
    ('David', 'Chen', 'david.chen@company.com', '555-0103', '2019-11-22', 'Marketing Director', 95000.00, 2, '456123789', '1982-11-30'),
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', '555-0104', '2022-01-10', 'Marketing Specialist', 55000.00, 2, '789123456', '1993-01-25'),
    ('Michael', 'Brown', 'michael.brown@company.com', '555-0105', '2018-07-30', 'IT Manager', 105000.00, 3, '321654987', '1980-08-12'),
    ('Emily', 'Wilson', 'emily.wilson@company.com', '555-0106', '2023-03-01', 'Software Developer', 85000.00, 3, '654987321', '1992-04-18');
GO

UPDATE Departments SET ManagerID = 1 WHERE DepartmentID = 1;
UPDATE Departments SET ManagerID = 3 WHERE DepartmentID = 2;
UPDATE Departments SET ManagerID = 5 WHERE DepartmentID = 3;

UPDATE Employees SET ManagerID = 1 WHERE EmployeeID = 2;
UPDATE Employees SET ManagerID = 3 WHERE EmployeeID = 4;
UPDATE Employees SET ManagerID = 5 WHERE EmployeeID = 6;
GO

INSERT INTO Customers (CompanyName, ContactName, City, Country, Phone, Email, CustomerType, CreditLimit, TaxID)
VALUES 
    ('Acme Corp', 'John Doe', 'New York', 'USA', '212-555-0101', 'acme@example.com', 'Corporate', 50000.00, 'TAX123456'),
    ('Global Tech', 'Jane Smith', 'London', 'UK', '44-20-5555-0102', 'global@example.com', 'Corporate', 75000.00, 'TAX789012'),
    ('City Retail', 'Bob Wilson', 'Chicago', 'USA', '312-555-0103', 'city@example.com', 'Retail', 15000.00, 'TAX345678'),
    ('Office Supplies Inc', 'Alice Brown', 'Toronto', 'Canada', '416-555-0104', 'office@example.com', 'Wholesale', 30000.00, 'TAX901234'),
    ('Tech Solutions', 'Charlie Davis', 'San Francisco', 'USA', '415-555-0105', 'tech@example.com', 'Corporate', 100000.00, 'TAX567890');
GO

INSERT INTO Products (ProductName, Category, SubCategory, UnitPrice, CostPrice, QuantityInStock)
VALUES 
    ('Laptop Pro', 'Electronics', 'Computers', 1299.99, 900.00, 50),
    ('Wireless Mouse', 'Electronics', 'Accessories', 39.99, 15.00, 200),
    ('Office Chair', 'Furniture', 'Chairs', 299.99, 150.00, 30),
    ('Desk Lamp', 'Home', 'Lighting', 49.99, 20.00, 100),
    ('Notebook', 'Office Supplies', 'Stationery', 12.99, 5.00, 500),
    ('Coffee Maker', 'Home Appliances', 'Kitchen', 89.99, 40.00, 75),
    ('Smartphone', 'Electronics', 'Phones', 799.99, 500.00, 150),
    ('Monitor 27"', 'Electronics', 'Displays', 349.99, 200.00, 40);
GO

INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, Freight, OrderStatus, PaymentMethod, PaymentStatus)
VALUES 
    (1, 2, '2024-01-15', '2024-01-25', '2024-01-20', 25.00, 'Delivered', 'Credit Card', 'Paid'),
    (2, 2, '2024-02-01', '2024-02-10', '2024-02-05', 45.00, 'Delivered', 'Bank Transfer', 'Paid'),
    (3, 4, '2024-02-15', '2024-02-28', '2024-02-20', 15.00, 'Delivered', 'Credit Card', 'Paid'),
    (1, 2, '2024-03-01', '2024-03-10', NULL, 30.00, 'Processing', 'Credit Card', 'Pending'),
    (4, 6, '2024-03-05', '2024-03-15', '2024-03-10', 20.00, 'Shipped', 'Purchase Order', 'Pending'),
    (5, 2, '2024-03-10', '2024-03-20', NULL, 50.00, 'Pending', 'Credit Card', 'Unpaid');
GO

INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES 
    (1, 1, 1299.99, 2, 5.00),
    (1, 2, 39.99, 5, 0.00),
    (2, 3, 299.99, 10, 10.00),
    (3, 4, 49.99, 20, 0.00),
    (4, 5, 12.99, 100, 15.00),
    (5, 6, 89.99, 5, 0.00),
    (5, 7, 799.99, 3, 8.00),
    (6, 8, 349.99, 8, 12.00);
GO

-- Section 2: Fundamental Concepts - Basic Views
--------------------------------------------------------------------
-- Creating simple views for data abstraction and security
--------------------------------------------------------------------

PRINT '=== SECTION 2: BASIC VIEWS ===';

-- 2.1 Create a simple view for employee directory
-- Purpose: Provide public-facing employee information without sensitive data
CREATE VIEW vw_EmployeeDirectory
AS
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    FullName,
    Email,
    Phone,
    JobTitle,
    HireDate,
    YearsOfService
FROM Employees
WHERE IsActive = 1;
GO

-- Test the view
SELECT * FROM vw_EmployeeDirectory
ORDER BY LastName, FirstName;
GO

-- 2.2 Create a view with calculated columns
-- Purpose: Provide enriched employee data with calculations
CREATE VIEW vw_EmployeeSummary
AS
SELECT 
    EmployeeID,
    FullName,
    JobTitle,
    HireDate,
    YearsOfService,
    Salary,
    Salary * 12 AS AnnualSalary,
    CASE 
        WHEN YearsOfService >= 5 THEN 'Senior'
        WHEN YearsOfService >= 2 THEN 'Mid-Level'
        ELSE 'Junior'
    END AS ExperienceLevel,
    CASE 
        WHEN Salary >= 90000 THEN 'High'
        WHEN Salary >= 60000 THEN 'Medium'
        ELSE 'Low'
    END AS SalaryBand
FROM Employees
WHERE IsActive = 1;
GO

-- Test the view
SELECT * FROM vw_EmployeeSummary
ORDER BY AnnualSalary DESC;
GO

-- 2.3 Create a view for active products
-- Purpose: Show only active, in-stock products
CREATE VIEW vw_ActiveProducts
AS
SELECT 
    ProductID,
    ProductCode,
    ProductName,
    Category,
    SubCategory,
    UnitPrice,
    QuantityInStock,
    CASE 
        WHEN QuantityInStock = 0 THEN 'Out of Stock'
        WHEN QuantityInStock <= ReorderLevel THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus,
    UnitPrice - CostPrice AS ProfitMargin
FROM Products
WHERE IsActive = 1
    AND DiscontinuedDate IS NULL;
GO

-- Test the view
SELECT * FROM vw_ActiveProducts
ORDER BY Category, ProductName;
GO

-- 2.4 Create a view with filtered data
-- Purpose: Show only high-value customers
CREATE VIEW vw_HighValueCustomers
AS
SELECT 
    CustomerID,
    CustomerCode,
    CompanyName,
    ContactName,
    City,
    Country,
    CustomerType,
    CreditLimit,
    CustomerSince,
    DATEDIFF(YEAR, CustomerSince, GETDATE()) AS CustomerForYears
FROM Customers
WHERE IsActive = 1
    AND CreditLimit >= 25000.00
    AND CustomerType IN ('Corporate', 'Wholesale');
GO

-- Test the view
SELECT * FROM vw_HighValueCustomers
ORDER BY CreditLimit DESC;
GO

-- Section 3: Core Functionality - Joins in Views
--------------------------------------------------------------------
-- Creating views that combine data from multiple tables
--------------------------------------------------------------------

PRINT '=== SECTION 3: VIEWS WITH JOINS ===';

-- 3.1 Create a view with INNER JOIN
-- Purpose: Combine employee and department information
CREATE VIEW vw_EmployeeDepartment
AS
SELECT 
    e.EmployeeID,
    e.FullName,
    e.JobTitle,
    e.Email,
    e.HireDate,
    e.Salary,
    d.DepartmentName,
    d.Location,
    d.Budget
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.IsActive = 1
    AND d.IsActive = 1;
GO

-- Test the view
SELECT * FROM vw_EmployeeDepartment
ORDER BY DepartmentName, Salary DESC;
GO

-- 3.2 Create a view with multiple joins
-- Purpose: Show complete order information
CREATE VIEW vw_OrderDetailsComplete
AS
SELECT 
    o.OrderID,
    o.OrderNumber,
    o.OrderDate,
    o.OrderStatus,
    o.PaymentStatus,
    c.CompanyName AS CustomerName,
    c.ContactName AS CustomerContact,
    e.FullName AS SalesPerson,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    od.LineTotal,
    o.Freight,
    (od.LineTotal + o.Freight) AS OrderLineTotal
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE c.IsActive = 1;
GO

-- Test the view
SELECT * FROM vw_OrderDetailsComplete
WHERE OrderStatus = 'Delivered'
ORDER BY OrderDate DESC;
GO

-- 3.3 Create a view with LEFT JOIN
-- Purpose: Show all departments with their employees (including empty departments)
CREATE VIEW vw_DepartmentEmployees
AS
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    d.Location,
    e.EmployeeID,
    e.FullName,
    e.JobTitle,
    e.HireDate,
    CASE 
        WHEN e.EmployeeID IS NULL THEN 'No Employees'
        ELSE CAST(COUNT(e.EmployeeID) OVER (PARTITION BY d.DepartmentID) AS VARCHAR) + ' employee(s)'
    END AS DepartmentStaffCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
WHERE d.IsActive = 1;
GO

-- Test the view
SELECT * FROM vw_DepartmentEmployees
ORDER BY DepartmentName, FullName;
GO

-- 3.4 Create a view with aggregation
-- Purpose: Show sales summary by employee
CREATE VIEW vw_EmployeeSalesSummary
AS
SELECT 
    e.EmployeeID,
    e.FullName,
    e.JobTitle,
    d.DepartmentName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(od.LineTotal) AS TotalSalesAmount,
    AVG(od.LineTotal) AS AverageOrderValue,
    MIN(o.OrderDate) AS FirstSaleDate,
    MAX(o.OrderDate) AS LastSaleDate
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE e.IsActive = 1
    AND o.OrderStatus NOT IN ('Cancelled')
GROUP BY e.EmployeeID, e.FullName, e.JobTitle, d.DepartmentName;
GO

-- Test the view
SELECT * FROM vw_EmployeeSalesSummary
ORDER BY TotalSalesAmount DESC;
GO

-- Section 4: Intermediate Techniques - Schema Binding and Security
--------------------------------------------------------------------
-- Using WITH SCHEMABINDING and WITH CHECK OPTION for security
--------------------------------------------------------------------

PRINT '=== SECTION 4: SCHEMA BINDING AND SECURITY ===';

-- 4.1 Create a view WITH SCHEMABINDING
-- Purpose: Prevent underlying table modifications that would break the view
-- Note: All objects must be schema-qualified (dbo.Employees, not just Employees)
CREATE VIEW vw_SecureEmployeeInfo
WITH SCHEMABINDING
AS
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email,
    JobTitle,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService
FROM dbo.Employees
WHERE IsActive = 1;
GO

-- Test the view
SELECT * FROM vw_SecureEmployeeInfo;
GO

-- Try to alter the underlying table (this will fail because of schema binding)
/*
-- This will fail:
ALTER TABLE Employees DROP COLUMN Email;
-- Error: Cannot DROP COLUMN 'Email' because it is being referenced by object 'vw_SecureEmployeeInfo'
*/
GO

-- 4.2 Create a view WITH CHECK OPTION
-- Purpose: Ensure data modifications through view respect WHERE clause
CREATE VIEW vw_ActiveEmployeesOnly
AS
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email,
    JobTitle,
    Salary
FROM Employees
WHERE IsActive = 1
WITH CHECK OPTION;  -- Prevents inserting/updating rows that would disappear from view
GO

-- Test the view
SELECT * FROM vw_ActiveEmployeesOnly;
GO

-- Try to insert through the view (this will work)
INSERT INTO vw_ActiveEmployeesOnly (FirstName, LastName, Email, JobTitle, Salary)
VALUES ('Test', 'User', 'test.user@company.com', 'Tester', 50000.00);
-- IsActive will default to 1, so it's visible through the view

-- Try to update through the view to make employee inactive (this will fail)
/*
UPDATE vw_ActiveEmployeesOnly 
SET IsActive = 0 
WHERE EmployeeID = 1;
-- Error: The attempted insert or update failed because the target view either 
-- specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION 
-- and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
*/
GO

-- 4.3 Create a view with encryption
-- Purpose: Hide view definition from users
CREATE VIEW vw_EncryptedSalesData
WITH ENCRYPTION
AS
SELECT 
    e.EmployeeID,
    e.FullName,
    SUM(od.LineTotal) AS TotalSales,
    AVG(od.Discount) AS AverageDiscount,
    COUNT(DISTINCT o.CustomerID) AS UniqueCustomers
FROM dbo.Employees e
INNER JOIN dbo.Orders o ON e.EmployeeID = o.EmployeeID
INNER JOIN dbo.OrderDetails od ON o.OrderID = od.OrderID
WHERE e.IsActive = 1
    AND o.OrderStatus = 'Delivered'
GROUP BY e.EmployeeID, e.FullName;
GO

-- Test the view
SELECT * FROM vw_EncryptedSalesData
ORDER BY TotalSales DESC;
GO

-- Try to view the definition (will return NULL because of encryption)
SELECT OBJECT_DEFINITION(OBJECT_ID('vw_EncryptedSalesData')) AS ViewDefinition;
GO

-- Section 5: Advanced Features - Indexed Views
--------------------------------------------------------------------
-- Creating indexed views for performance optimization
--------------------------------------------------------------------

PRINT '=== SECTION 5: INDEXED VIEWS ===';

-- 5.1 Create a schema-bound view for indexing
-- Requirements: View must be schema-bound, cannot use *, must use two-part names
CREATE VIEW vw_ProductSalesSummary
WITH SCHEMABINDING
AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    COUNT_BIG(*) AS TransactionCount,
    SUM(od.Quantity) AS TotalQuantitySold,
    SUM(od.LineTotal) AS TotalRevenue,
    AVG(od.Discount) AS AverageDiscount
FROM dbo.OrderDetails od
INNER JOIN dbo.Products p ON od.ProductID = p.ProductID
INNER JOIN dbo.Orders o ON od.OrderID = o.OrderID
WHERE o.OrderStatus = 'Delivered'
    AND p.IsActive = 1
GROUP BY p.ProductID, p.ProductName, p.Category;
GO

-- Test the view
SELECT * FROM vw_ProductSalesSummary
ORDER BY TotalRevenue DESC;
GO

-- 5.2 Create unique clustered index on the view
-- This materializes the view and stores it physically
CREATE UNIQUE CLUSTERED INDEX IX_vw_ProductSalesSummary
ON vw_ProductSalesSummary (ProductID);
GO

-- 5.3 Create non-clustered indexes on the view
CREATE INDEX IX_vw_ProductSalesSummary_Category 
ON vw_ProductSalesSummary (Category)
INCLUDE (TotalRevenue, TotalQuantitySold);
GO

CREATE INDEX IX_vw_ProductSalesSummary_Revenue 
ON vw_ProductSalesSummary (TotalRevenue DESC)
INCLUDE (ProductName, Category);
GO

-- Test performance of indexed view
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Query that will use the indexed view
SELECT 
    Category,
    COUNT(*) AS ProductCount,
    SUM(TotalRevenue) AS CategoryRevenue,
    AVG(TotalQuantitySold) AS AvgQuantitySold
FROM vw_ProductSalesSummary
GROUP BY Category
ORDER BY CategoryRevenue DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- 5.4 Create another indexed view for frequently queried aggregations
CREATE VIEW vw_CustomerOrderSummary
WITH SCHEMABINDING
AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.CustomerType,
    COUNT_BIG(*) AS OrderCount,
    SUM(od.LineTotal) AS TotalSpent,
    MIN(o.OrderDate) AS FirstOrderDate,
    MAX(o.OrderDate) AS LastOrderDate,
    AVG(od.LineTotal) AS AverageOrderValue
FROM dbo.Customers c
INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails od ON o.OrderID = od.OrderID
WHERE c.IsActive = 1
    AND o.OrderStatus = 'Delivered'
GROUP BY c.CustomerID, c.CompanyName, c.CustomerType;
GO

-- Create clustered index
CREATE UNIQUE CLUSTERED INDEX IX_vw_CustomerOrderSummary
ON vw_CustomerOrderSummary (CustomerID);
GO

-- Test the indexed view
SELECT * FROM vw_CustomerOrderSummary
WHERE CustomerType = 'Corporate'
ORDER BY TotalSpent DESC;
GO

-- Section 6: Advanced Features - Partitioned Views
--------------------------------------------------------------------
-- Creating partitioned views for horizontal partitioning
--------------------------------------------------------------------

PRINT '=== SECTION 6: PARTITIONED VIEWS ===';

-- 6.1 Create partitioned tables based on region
CREATE TABLE Orders_NorthAmerica (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME,
    OrderStatus VARCHAR(20),
    Region VARCHAR(20) DEFAULT 'NorthAmerica',
    CHECK (Region = 'NorthAmerica')
);

CREATE TABLE Orders_Europe (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME,
    OrderStatus VARCHAR(20),
    Region VARCHAR(20) DEFAULT 'Europe',
    CHECK (Region = 'Europe')
);

CREATE TABLE Orders_Asia (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME,
    OrderStatus VARCHAR(20),
    Region VARCHAR(20) DEFAULT 'Asia',
    CHECK (Region = 'Asia')
);
GO

-- 6.2 Create a partitioned view
CREATE VIEW vw_AllOrders
AS
SELECT * FROM Orders_NorthAmerica
UNION ALL
SELECT * FROM Orders_Europe
UNION ALL
SELECT * FROM Orders_Asia;
GO

-- Insert sample data
INSERT INTO Orders_NorthAmerica (OrderID, CustomerID, OrderDate, OrderStatus)
VALUES (1001, 1, '2024-01-15', 'Delivered'),
       (1002, 3, '2024-02-01', 'Processing');

INSERT INTO Orders_Europe (OrderID, CustomerID, OrderDate, OrderStatus)
VALUES (2001, 2, '2024-01-20', 'Delivered');

INSERT INTO Orders_Asia (OrderID, CustomerID, OrderDate, OrderStatus)
VALUES (3001, 5, '2024-02-15', 'Pending');
GO

-- Test the partitioned view
SELECT * FROM vw_AllOrders
ORDER BY OrderDate DESC;
GO

-- Query with WHERE clause that can be partitioned
-- SQL Server will query only the relevant partition
SELECT * FROM vw_AllOrders
WHERE Region = 'Europe';
GO

-- Section 7: Real-World Application - Complex Business Views
--------------------------------------------------------------------
-- Creating views for complex business reporting and analytics
--------------------------------------------------------------------

PRINT '=== SECTION 7: COMPLEX BUSINESS VIEWS ===';

-- 7.1 Create a view for sales dashboard
CREATE VIEW vw_SalesDashboard
AS
WITH MonthlySales AS (
    SELECT 
        YEAR(o.OrderDate) AS OrderYear,
        MONTH(o.OrderDate) AS OrderMonth,
        DATENAME(MONTH, o.OrderDate) AS MonthName,
        COUNT(DISTINCT o.OrderID) AS OrderCount,
        COUNT(DISTINCT o.CustomerID) AS CustomerCount,
        SUM(od.LineTotal) AS TotalRevenue,
        AVG(od.LineTotal) AS AverageOrderValue,
        SUM(o.Freight) AS TotalFreight
    FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.OrderStatus = 'Delivered'
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), DATENAME(MONTH, o.OrderDate)
),
EmployeePerformance AS (
    SELECT 
        e.EmployeeID,
        e.FullName,
        d.DepartmentName,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        SUM(od.LineTotal) AS TotalSales,
        RANK() OVER (ORDER BY SUM(od.LineTotal) DESC) AS SalesRank
    FROM Employees e
    LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1
        AND (o.OrderID IS NULL OR o.OrderStatus = 'Delivered')
    GROUP BY e.EmployeeID, e.FullName, d.DepartmentName
),
TopProducts AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        p.Category,
        SUM(od.Quantity) AS TotalQuantitySold,
        SUM(od.LineTotal) AS TotalRevenue,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(od.LineTotal) DESC) AS CategoryRank
    FROM Products p
    INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE p.IsActive = 1
        AND o.OrderStatus = 'Delivered'
    GROUP BY p.ProductID, p.ProductName, p.Category
)
SELECT 
    'Monthly Summary' AS ReportSection,
    OrderYear,
    OrderMonth,
    MonthName,
    OrderCount,
    CustomerCount,
    TotalRevenue,
    AverageOrderValue,
    TotalFreight,
    NULL AS EmployeeName,
    NULL AS DepartmentName,
    NULL AS ProductName,
    NULL AS Category
FROM MonthlySales

UNION ALL

SELECT 
    'Employee Performance' AS ReportSection,
    NULL AS OrderYear,
    NULL AS OrderMonth,
    NULL AS MonthName,
    TotalOrders AS OrderCount,
    NULL AS CustomerCount,
    TotalSales AS TotalRevenue,
    NULL AS AverageOrderValue,
    NULL AS TotalFreight,
    FullName AS EmployeeName,
    DepartmentName,
    NULL AS ProductName,
    NULL AS Category
FROM EmployeePerformance
WHERE SalesRank <= 5

UNION ALL

SELECT 
    'Top Products' AS ReportSection,
    NULL AS OrderYear,
    NULL AS OrderMonth,
    NULL AS MonthName,
    NULL AS OrderCount,
    NULL AS CustomerCount,
    TotalRevenue,
    NULL AS AverageOrderValue,
    NULL AS TotalFreight,
    NULL AS EmployeeName,
    NULL AS DepartmentName,
    ProductName,
    Category
FROM TopProducts
WHERE CategoryRank <= 3;
GO

-- Test the dashboard view
SELECT * FROM vw_SalesDashboard
ORDER BY ReportSection, TotalRevenue DESC;
GO

-- 7.2 Create a view for inventory management
CREATE VIEW vw_InventoryManagement
AS
SELECT 
    p.ProductID,
    p.ProductCode,
    p.ProductName,
    p.Category,
    p.QuantityInStock,
    p.ReorderLevel,
    p.UnitPrice,
    p.CostPrice,
    -- Stock analysis
    CASE 
        WHEN p.QuantityInStock = 0 THEN 'Out of Stock'
        WHEN p.QuantityInStock <= p.ReorderLevel THEN 'Reorder Needed'
        WHEN p.QuantityInStock <= p.ReorderLevel * 2 THEN 'Low Stock'
        ELSE 'Adequate Stock'
    END AS StockStatus,
    -- Sales data
    ISNULL(ps.TotalQuantitySold, 0) AS Last30DaysSold,
    ISNULL(ps.TotalRevenue, 0) AS Last30DaysRevenue,
    -- Turnover rate
    CASE 
        WHEN p.QuantityInStock > 0 
        THEN CAST(ISNULL(ps.TotalQuantitySold, 0) * 1.0 / p.QuantityInStock AS DECIMAL(5,2))
        ELSE 0 
    END AS StockTurnoverRate,
    -- Value calculations
    p.QuantityInStock * p.CostPrice AS InventoryValueAtCost,
    p.QuantityInStock * p.UnitPrice AS InventoryValueAtPrice,
    -- Days of supply
    CASE 
        WHEN ISNULL(ps.DailyAverageSold, 0) > 0 
        THEN CAST(p.QuantityInStock * 1.0 / ps.DailyAverageSold AS DECIMAL(5,1))
        ELSE 999 
    END AS DaysOfSupply
FROM Products p
LEFT JOIN (
    SELECT 
        od.ProductID,
        SUM(od.Quantity) AS TotalQuantitySold,
        SUM(od.LineTotal) AS TotalRevenue,
        AVG(od.Quantity * 1.0) AS DailyAverageSold
    FROM OrderDetails od
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE o.OrderDate >= DATEADD(DAY, -30, GETDATE())
        AND o.OrderStatus = 'Delivered'
    GROUP BY od.ProductID
) ps ON p.ProductID = ps.ProductID
WHERE p.IsActive = 1
    AND p.DiscontinuedDate IS NULL;
GO

-- Test the inventory view
SELECT 
    Category,
    COUNT(*) AS ProductCount,
    SUM(InventoryValueAtCost) AS TotalInventoryValue,
    AVG(DaysOfSupply) AS AvgDaysOfSupply,
    SUM(CASE WHEN StockStatus = 'Reorder Needed' THEN 1 ELSE 0 END) AS ProductsToReorder
FROM vw_InventoryManagement
GROUP BY Category
ORDER BY TotalInventoryValue DESC;
GO

-- Section 8: View Management and Metadata
--------------------------------------------------------------------
-- Querying system views to manage and understand existing views
--------------------------------------------------------------------

PRINT '=== SECTION 8: VIEW MANAGEMENT ===';

-- 8
