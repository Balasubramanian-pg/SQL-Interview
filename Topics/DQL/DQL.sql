/*
================================================================================
COMPREHENSIVE SQL DQL TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to Data Query Language (DQL) with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- DQL = Data Query Language (SELECT statements)
-- Focus: Data retrieval, filtering, aggregation, and analysis
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DQLTutorialDB')
BEGIN
    ALTER DATABASE DQLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DQLTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE DQLTutorialDB;
GO

USE DQLTutorialDB;
GO

-- Enable statistics for query optimization
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create comprehensive sample database schema
-- Multi-table relational design for complex query scenarios
--------------------------------------------------------------------

-- Create Departments table
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    Budget DECIMAL(15,2) DEFAULT 0.00,
    Location NVARCHAR(100),
    EstablishedDate DATE DEFAULT GETDATE()
);
GO

-- Create Employees table
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
    IsActive BIT DEFAULT 1,
    -- Computed columns
    FullName AS (FirstName + ' ' + LastName) PERSISTED,
    AnnualSalary AS (Salary * 12) PERSISTED,
    -- Foreign key
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID),
    -- Check constraints
    CONSTRAINT CHK_Employees_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Employees_Commission CHECK (CommissionPct BETWEEN 0 AND 100)
);
GO

-- Create self-referencing foreign key for ManagerID
ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID)
    REFERENCES Employees(EmployeeID);
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
    LastRestockDate DATE NULL,
    -- Check constraints
    CONSTRAINT CHK_Products_Price CHECK (UnitPrice > 0 AND CostPrice > 0),
    CONSTRAINT CHK_Products_Stock CHECK (QuantityInStock >= 0)
);
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
    Fax VARCHAR(20),
    Email NVARCHAR(100),
    CustomerType VARCHAR(20) DEFAULT 'Retail'
        CHECK (CustomerType IN ('Retail', 'Wholesale', 'Corporate', 'Government')),
    CreditLimit DECIMAL(15,2) DEFAULT 5000.00,
    CustomerSince DATE DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
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
    ShipName NVARCHAR(100),
    ShipAddress NVARCHAR(200),
    ShipCity NVARCHAR(50),
    ShipRegion NVARCHAR(50),
    ShipPostalCode VARCHAR(20),
    ShipCountry NVARCHAR(50),
    OrderStatus VARCHAR(20) DEFAULT 'Pending'
        CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'On Hold')),
    -- Computed columns
    DaysToShip AS (DATEDIFF(DAY, OrderDate, ISNULL(ShippedDate, GETDATE()))),
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
CREATE INDEX IX_Orders_ShippedDate ON Orders(ShippedDate);
CREATE INDEX IX_OrderDetails_OrderID ON OrderDetails(OrderID);
CREATE INDEX IX_OrderDetails_ProductID ON OrderDetails(ProductID);
CREATE INDEX IX_Products_Category ON Products(Category);
CREATE INDEX IX_Customers_Country ON Customers(Country);
CREATE INDEX IX_Customers_City ON Customers(City);
GO

-- Create filtered index for active customers
CREATE INDEX IX_Customers_Active ON Customers(CustomerID)
WHERE IsActive = 1;
GO

-- Section 2: Fundamental Concepts - Basic SELECT Queries
--------------------------------------------------------------------
-- Basic SELECT syntax, column selection, aliases, and filtering
--------------------------------------------------------------------

PRINT '=== SECTION 2: BASIC SELECT QUERIES ===';

-- 2.1 SELECT all columns from a table
-- Syntax: SELECT * FROM table_name
SELECT * FROM Departments;
GO

-- 2.2 SELECT specific columns
-- Syntax: SELECT column1, column2 FROM table_name
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email,
    HireDate
FROM Employees;
GO

-- 2.3 Column aliases for readability
-- Syntax: SELECT column AS alias FROM table
SELECT 
    EmployeeID AS ID,
    FirstName AS 'First Name',
    LastName AS 'Last Name',
    Email AS 'Email Address',
    HireDate AS 'Date Hired'
FROM Employees;
GO

-- 2.4 Using expressions in SELECT
SELECT 
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Salary,
    Salary * 0.1 AS BonusAmount,  -- 10% bonus calculation
    Salary * 12 AS AnnualSalary
FROM Employees;
GO

-- 2.5 Using DISTINCT to remove duplicates
SELECT DISTINCT JobTitle FROM Employees;
SELECT DISTINCT City, Country FROM Customers;
GO

-- 2.6 Using TOP to limit results
-- Syntax: SELECT TOP n column FROM table
SELECT TOP 5 
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Employees
ORDER BY Salary DESC;  -- Top 5 highest paid employees
GO

-- 2.7 Using TOP with PERCENT
SELECT TOP 10 PERCENT
    CustomerID,
    CompanyName,
    CreditLimit
FROM Customers
ORDER BY CreditLimit DESC;  -- Top 10% of customers by credit limit
GO

-- 2.8 Using TOP with ties
SELECT TOP 5 WITH TIES
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Employees
ORDER BY Salary;  -- Includes all employees with same salary as 5th
GO

-- Insert sample data for testing
INSERT INTO Departments (DepartmentName, ManagerID, Budget, Location)
VALUES 
    ('Sales', NULL, 500000.00, 'New York'),
    ('Marketing', NULL, 300000.00, 'Chicago'),
    ('IT', NULL, 800000.00, 'San Francisco'),
    ('Finance', NULL, 400000.00, 'Boston'),
    ('HR', NULL, 200000.00, 'Austin');
GO

INSERT INTO Employees (FirstName, LastName, Email, Phone, HireDate, JobTitle, Salary, DepartmentID)
VALUES 
    ('John', 'Smith', 'john.smith@company.com', '555-0101', '2020-03-15', 'Sales Manager', 85000.00, 1),
    ('Maria', 'Garcia', 'maria.garcia@company.com', '555-0102', '2021-06-01', 'Sales Representative', 65000.00, 1),
    ('David', 'Chen', 'david.chen@company.com', '555-0103', '2019-11-22', 'Marketing Director', 95000.00, 2),
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', '555-0104', '2022-01-10', 'Marketing Specialist', 55000.00, 2),
    ('Michael', 'Brown', 'michael.brown@company.com', '555-0105', '2018-07-30', 'IT Manager', 105000.00, 3),
    ('Emily', 'Wilson', 'emily.wilson@company.com', '555-0106', '2023-03-01', 'Software Developer', 85000.00, 3),
    ('Robert', 'Taylor', 'robert.taylor@company.com', '555-0107', '2020-09-15', 'Financial Analyst', 75000.00, 4),
    ('Jennifer', 'Lee', 'jennifer.lee@company.com', '555-0108', '2021-12-05', 'HR Manager', 80000.00, 5);
GO

-- Update Managers
UPDATE Departments SET ManagerID = 1 WHERE DepartmentID = 1;  -- John manages Sales
UPDATE Departments SET ManagerID = 3 WHERE DepartmentID = 2;  -- David manages Marketing
UPDATE Departments SET ManagerID = 5 WHERE DepartmentID = 3;  -- Michael manages IT
UPDATE Departments SET ManagerID = 7 WHERE DepartmentID = 4;  -- Robert manages Finance
UPDATE Departments SET ManagerID = 8 WHERE DepartmentID = 5;  -- Jennifer manages HR

UPDATE Employees SET ManagerID = 1 WHERE EmployeeID IN (2);  -- Maria reports to John
UPDATE Employees SET ManagerID = 3 WHERE EmployeeID IN (4);  -- Sarah reports to David
UPDATE Employees SET ManagerID = 5 WHERE EmployeeID IN (6);  -- Emily reports to Michael
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

INSERT INTO Customers (CompanyName, ContactName, ContactTitle, City, Country, Phone, CustomerType, CreditLimit)
VALUES 
    ('Acme Corp', 'John Doe', 'Purchasing Manager', 'New York', 'USA', '212-555-0101', 'Corporate', 50000.00),
    ('Global Tech', 'Jane Smith', 'Director', 'London', 'UK', '44-20-5555-0102', 'Corporate', 75000.00),
    ('City Retail', 'Bob Wilson', 'Store Manager', 'Chicago', 'USA', '312-555-0103', 'Retail', 15000.00),
    ('Office Supplies Inc', 'Alice Brown', 'Owner', 'Toronto', 'Canada', '416-555-0104', 'Wholesale', 30000.00),
    ('Tech Solutions', 'Charlie Davis', 'CEO', 'San Francisco', 'USA', '415-555-0105', 'Corporate', 100000.00);
GO

INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, Freight, ShipCity, ShipCountry, OrderStatus)
VALUES 
    (1, 2, '2024-01-15', '2024-01-25', '2024-01-20', 25.00, 'New York', 'USA', 'Delivered'),
    (2, 2, '2024-02-01', '2024-02-10', '2024-02-05', 45.00, 'London', 'UK', 'Delivered'),
    (3, 4, '2024-02-15', '2024-02-28', '2024-02-20', 15.00, 'Chicago', 'USA', 'Delivered'),
    (1, 2, '2024-03-01', '2024-03-10', NULL, 30.00, 'New York', 'USA', 'Processing'),
    (4, 6, '2024-03-05', '2024-03-15', '2024-03-10', 20.00, 'Toronto', 'Canada', 'Shipped'),
    (5, 2, '2024-03-10', '2024-03-20', NULL, 50.00, 'San Francisco', 'USA', 'Pending');
GO

INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES 
    (1, 1, 1299.99, 2, 5.00),   -- 2 Laptops with 5% discount
    (1, 2, 39.99, 5, 0.00),     -- 5 Mice
    (2, 3, 299.99, 10, 10.00),  -- 10 Chairs with 10% discount
    (3, 4, 49.99, 20, 0.00),    -- 20 Lamps
    (4, 5, 12.99, 100, 15.00),  -- 100 Notebooks with 15% discount
    (5, 6, 89.99, 5, 0.00),     -- 5 Coffee Makers
    (5, 7, 799.99, 3, 8.00),    -- 3 Smartphones with 8% discount
    (6, 8, 349.99, 8, 12.00);   -- 8 Monitors with 12% discount
GO

-- Section 3: Core Functionality - WHERE Clause and Filtering
--------------------------------------------------------------------
-- Filtering data with conditions, operators, and patterns
--------------------------------------------------------------------

PRINT '=== SECTION 3: FILTERING WITH WHERE CLAUSE ===';

-- 3.1 Basic WHERE clause with equality
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    JobTitle,
    Salary
FROM Employees
WHERE DepartmentID = 3;  -- IT department employees
GO

-- 3.2 WHERE with comparison operators
SELECT 
    ProductID,
    ProductName,
    UnitPrice,
    QuantityInStock
FROM Products
WHERE UnitPrice > 100.00;  -- Products more than $100
GO

SELECT 
    EmployeeID,
    FirstName,
    LastName,
    HireDate
FROM Employees
WHERE HireDate >= '2022-01-01';  -- Employees hired in 2022 or later
GO

-- 3.3 WHERE with multiple conditions (AND)
SELECT 
    CustomerID,
    CompanyName,
    City,
    Country,
    CreditLimit
FROM Customers
WHERE Country = 'USA' 
    AND CreditLimit > 20000.00;  -- US customers with high credit limit
GO

-- 3.4 WHERE with OR operator
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    JobTitle,
    DepartmentID
FROM Employees
WHERE DepartmentID = 1 OR DepartmentID = 3;  -- Sales or IT department
GO

-- 3.5 WHERE with IN operator
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    JobTitle,
    Salary
FROM Employees
WHERE JobTitle IN ('Sales Manager', 'Marketing Director', 'IT Manager');  -- Manager positions
GO

SELECT 
    CustomerID,
    CompanyName,
    City,
    Country
FROM Customers
WHERE Country IN ('USA', 'Canada', 'UK');  -- Customers in specific countries
GO

-- 3.6 WHERE with BETWEEN operator
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Salary
FROM Employees
WHERE Salary BETWEEN 60000 AND 90000;  -- Employees with salary between 60k and 90k
GO

SELECT 
    OrderID,
    OrderDate,
    CustomerID,
    Freight
FROM Orders
WHERE OrderDate BETWEEN '2024-02-01' AND '2024-02-28';  -- February 2024 orders
GO

-- 3.7 WHERE with LIKE operator and wildcards
-- % = any string of zero or more characters
-- _ = any single character
-- [] = any single character within the specified range
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Employees
WHERE Email LIKE '%@company.com';  -- Company email addresses
GO

SELECT 
    CustomerID,
    CompanyName,
    ContactName
FROM Customers
WHERE CompanyName LIKE 'Tech%';  -- Companies starting with 'Tech'
GO

SELECT 
    ProductID,
    ProductName,
    Category
FROM Products
WHERE ProductName LIKE '%Pro%';  -- Products containing 'Pro'
GO

SELECT 
    EmployeeID,
    FirstName,
    LastName
FROM Employees
WHERE FirstName LIKE 'J%n';  -- Names starting with J and ending with n
GO

-- 3.8 WHERE with IS NULL and IS NOT NULL
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    ManagerID
FROM Employees
WHERE ManagerID IS NULL;  -- Employees with no manager (top-level)
GO

SELECT 
    OrderID,
    OrderDate,
    ShippedDate
FROM Orders
WHERE ShippedDate IS NOT NULL;  -- Orders that have been shipped
GO

-- 3.9 WHERE with NOT operator
SELECT 
    ProductID,
    ProductName,
    Category,
    UnitPrice
FROM Products
WHERE NOT Category = 'Electronics';  -- Products not in Electronics category
GO

SELECT 
    CustomerID,
    CompanyName,
    Country
FROM Customers
WHERE NOT Country IN ('USA', 'Canada');  -- Customers not in USA or Canada
GO

-- 3.10 Complex WHERE conditions with parentheses
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Employees
WHERE (DepartmentID = 1 AND Salary > 70000)
    OR (DepartmentID = 3 AND Salary < 100000);  -- Complex condition
GO

-- Section 4: Core Functionality - ORDER BY and Sorting
--------------------------------------------------------------------
-- Sorting results with ORDER BY, multiple columns, and custom sorting
--------------------------------------------------------------------

PRINT '=== SECTION 4: SORTING WITH ORDER BY ===';

-- 4.1 Basic ORDER BY ascending (default)
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    HireDate
FROM Employees
ORDER BY HireDate;  -- Sort by hire date ascending
GO

-- 4.2 ORDER BY descending
SELECT 
    ProductID,
    ProductName,
    UnitPrice,
    QuantityInStock
FROM Products
ORDER BY UnitPrice DESC;  -- Most expensive products first
GO

-- 4.3 ORDER BY multiple columns
SELECT 
    CustomerID,
    CompanyName,
    City,
    Country
FROM Customers
ORDER BY Country ASC, City ASC;  -- Sort by country, then by city
GO

-- 4.4 ORDER BY with expressions
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Salary,
    Salary * 12 AS AnnualSalary
FROM Employees
ORDER BY AnnualSalary DESC;  -- Sort by computed column
GO

-- 4.5 ORDER BY with column position
SELECT 
    FirstName,
    LastName,
    Salary,
    HireDate
FROM Employees
ORDER BY 3 DESC, 4 ASC;  -- Sort by Salary (3rd column), then HireDate (4th column)
-- Note: Using column positions is less readable but sometimes used
GO

-- 4.6 ORDER BY with CASE for custom sorting
SELECT 
    ProductID,
    ProductName,
    Category,
    UnitPrice
FROM Products
ORDER BY 
    CASE 
        WHEN Category = 'Electronics' THEN 1
        WHEN Category = 'Furniture' THEN 2
        WHEN Category = 'Home' THEN 3
        ELSE 4
    END,
    UnitPrice DESC;  -- Custom category order, then price
GO

-- 4.7 ORDER BY with NULLS handling
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    ManagerID
FROM Employees
ORDER BY 
    CASE WHEN ManagerID IS NULL THEN 0 ELSE 1 END,  -- NULLs first
    ManagerID;
GO

-- Section 5: Intermediate Techniques - JOIN Operations
--------------------------------------------------------------------
-- Combining data from multiple tables with various JOIN types
--------------------------------------------------------------------

PRINT '=== SECTION 5: JOIN OPERATIONS ===';

-- 5.1 INNER JOIN (most common)
-- Returns only matching rows from both tables
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.JobTitle,
    d.DepartmentName,
    d.Location
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID;
GO

-- 5.2 INNER JOIN with multiple tables
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CompanyName,
    c.ContactName,
    e.FirstName + ' ' + e.LastName AS SalesPerson,
    o.OrderStatus
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID;
GO

-- 5.3 INNER JOIN with filtering
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CompanyName,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount/100)) AS OrderTotal
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'Delivered'
    AND YEAR(o.OrderDate) = 2024
GROUP BY o.OrderID, o.OrderDate, c.CompanyName
ORDER BY OrderTotal DESC;
GO

-- 5.4 LEFT JOIN (LEFT OUTER JOIN)
-- Returns all rows from left table, matching rows from right table
SELECT 
    d.DepartmentName,
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.JobTitle
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
ORDER BY d.DepartmentName, e.LastName;
GO

-- 5.5 LEFT JOIN to find departments with no employees
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    d.Location
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
WHERE e.EmployeeID IS NULL;  -- Departments without employees
GO

-- 5.6 RIGHT JOIN (RIGHT OUTER JOIN)
-- Returns all rows from right table, matching rows from left table
-- Less common than LEFT JOIN (usually rewritten as LEFT JOIN)
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Departments d
RIGHT JOIN Employees e ON d.DepartmentID = e.DepartmentID
ORDER BY d.DepartmentName;
GO

-- 5.7 FULL OUTER JOIN
-- Returns all rows from both tables, with NULLs where no match
-- Useful for finding mismatches in both directions
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    d.DepartmentID,
    d.DepartmentName
FROM Employees e
FULL OUTER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY 
    CASE WHEN e.EmployeeID IS NULL THEN 1 ELSE 0 END,
    CASE WHEN d.DepartmentID IS NULL THEN 1 ELSE 0 END;
GO

-- 5.8 CROSS JOIN (Cartesian Product)
-- Returns all possible combinations
-- Use with caution - can produce very large result sets
SELECT 
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM Employees e
CROSS JOIN Departments d
WHERE e.DepartmentID = 1  -- Limit to avoid huge results
    AND d.DepartmentID IN (1, 2, 3);
GO

-- 5.9 SELF JOIN (joining table to itself)
-- Useful for hierarchical data (employees and managers)
SELECT 
    emp.EmployeeID,
    emp.FirstName + ' ' + emp.LastName AS EmployeeName,
    emp.JobTitle,
    mgr.FirstName + ' ' + mgr.LastName AS ManagerName,
    mgr.JobTitle AS ManagerTitle
FROM Employees emp
LEFT JOIN Employees mgr ON emp.ManagerID = mgr.EmployeeID
ORDER BY mgr.LastName, emp.LastName;
GO

-- 5.10 Joining with subqueries
SELECT 
    d.DepartmentName,
    emp_stats.EmployeeCount,
    emp_stats.AvgSalary
FROM Departments d
LEFT JOIN (
    SELECT 
        DepartmentID,
        COUNT(*) AS EmployeeCount,
        AVG(Salary) AS AvgSalary
    FROM Employees
    WHERE IsActive = 1
    GROUP BY DepartmentID
) emp_stats ON d.DepartmentID = emp_stats.DepartmentID
ORDER BY emp_stats.AvgSalary DESC;
GO

-- Section 6: Intermediate Techniques - Aggregation and Grouping
--------------------------------------------------------------------
-- Using GROUP BY, aggregate functions, and HAVING clause
--------------------------------------------------------------------

PRINT '=== SECTION 6: AGGREGATION AND GROUPING ===';

-- 6.1 Basic aggregate functions
SELECT 
    COUNT(*) AS TotalEmployees,
    AVG(Salary) AS AverageSalary,
    MIN(Salary) AS MinimumSalary,
    MAX(Salary) AS MaximumSalary,
    SUM(Salary) AS TotalSalaryExpense
FROM Employees
WHERE IsActive = 1;
GO

-- 6.2 GROUP BY single column
SELECT 
    DepartmentID,
    COUNT(*) AS EmployeeCount,
    AVG(Salary) AS AverageSalary
FROM Employees
WHERE IsActive = 1
GROUP BY DepartmentID
ORDER BY AverageSalary DESC;
GO

-- 6.3 GROUP BY multiple columns
SELECT 
    d.DepartmentName,
    e.JobTitle,
    COUNT(*) AS EmployeeCount,
    AVG(e.Salary) AS AverageSalary
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.IsActive = 1
GROUP BY d.DepartmentName, e.JobTitle
ORDER BY d.DepartmentName, AverageSalary DESC;
GO

-- 6.4 GROUP BY with expressions
SELECT 
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(*) AS OrderCount,
    SUM(Freight) AS TotalFreight
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear DESC, OrderMonth DESC;
GO

-- 6.5 HAVING clause (filtering groups)
-- WHERE filters rows, HAVING filters groups
SELECT 
    c.Country,
    COUNT(*) AS CustomerCount,
    AVG(CreditLimit) AS AvgCreditLimit
FROM Customers c
WHERE c.IsActive = 1
GROUP BY c.Country
HAVING COUNT(*) > 1  -- Countries with more than 1 customer
    AND AVG(CreditLimit) > 20000  -- Average credit limit > 20k
ORDER BY AvgCreditLimit DESC;
GO

-- 6.6 GROUP BY with ROLLUP (subtotals)
SELECT 
    d.DepartmentName,
    e.JobTitle,
    COUNT(*) AS EmployeeCount,
    SUM(e.Salary) AS TotalSalary
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.IsActive = 1
GROUP BY ROLLUP(d.DepartmentName, e.JobTitle)
ORDER BY 
    CASE WHEN d.DepartmentName IS NULL THEN 1 ELSE 0 END,
    d.DepartmentName,
    CASE WHEN e.JobTitle IS NULL THEN 1 ELSE 0 END,
    e.JobTitle;
GO

-- 6.7 GROUP BY with CUBE (all combinations)
SELECT 
    c.Country,
    c.CustomerType,
    COUNT(*) AS CustomerCount,
    AVG(CreditLimit) AS AvgCreditLimit
FROM Customers c
WHERE c.IsActive = 1
GROUP BY CUBE(c.Country, c.CustomerType)
ORDER BY 
    CASE WHEN c.Country IS NULL THEN 1 ELSE 0 END,
    c.Country,
    CASE WHEN c.CustomerType IS NULL THEN 1 ELSE 0 END,
    c.CustomerType;
GO

-- 6.8 GROUPING SETS (specific groupings)
SELECT 
    c.Country,
    c.City,
    c.CustomerType,
    COUNT(*) AS CustomerCount
FROM Customers c
GROUP BY GROUPING SETS (
    (c.Country, c.City),           -- Group by country and city
    (c.Country, c.CustomerType),   -- Group by country and type
    (c.Country),                   -- Group by country only
    ()                             -- Grand total
)
ORDER BY 
    CASE WHEN c.Country IS NULL THEN 1 ELSE 0 END,
    c.Country,
    CASE WHEN c.City IS NULL THEN 1 ELSE 0 END,
    c.City,
    CASE WHEN c.CustomerType IS NULL THEN 1 ELSE 0 END,
    c.CustomerType;
GO

-- 6.9 DISTINCT with aggregates
SELECT 
    COUNT(DISTINCT Country) AS UniqueCountries,
    COUNT(DISTINCT City) AS UniqueCities,
    COUNT(*) AS TotalCustomers
FROM Customers;
GO

-- Section 7: Advanced Features - Subqueries and CTEs
--------------------------------------------------------------------
-- Using subqueries in SELECT, FROM, WHERE, and Common Table Expressions
--------------------------------------------------------------------

PRINT '=== SECTION 7: SUBQUERIES AND CTEs ===';

-- 7.1 Scalar subquery in SELECT
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.Salary,
    e.Salary - (SELECT AVG(Salary) FROM Employees) AS DifferenceFromAvg,
    (SELECT AVG(Salary) FROM Employees) AS CompanyAverageSalary
FROM Employees e
ORDER BY DifferenceFromAvg DESC;
GO

-- 7.2 Correlated subquery in WHERE
-- Subquery references outer query
SELECT 
    e1.EmployeeID,
    e1.FirstName,
    e1.LastName,
    e1.Salary,
    e1.DepartmentID
FROM Employees e1
WHERE e1.Salary > (
    SELECT AVG(e2.Salary)
    FROM Employees e2
    WHERE e2.DepartmentID = e1.DepartmentID
);  -- Employees earning more than department average
GO

-- 7.3 Subquery in FROM clause (derived table)
SELECT 
    dept_stats.DepartmentName,
    dept_stats.EmployeeCount,
    dept_stats.AverageSalary
FROM (
    SELECT 
        d.DepartmentName,
        COUNT(e.EmployeeID) AS EmployeeCount,
        AVG(e.Salary) AS AverageSalary
    FROM Departments d
    LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
    WHERE e.IsActive = 1 OR e.EmployeeID IS NULL
    GROUP BY d.DepartmentName
) dept_stats
WHERE dept_stats.EmployeeCount > 0
ORDER BY dept_stats.AverageSalary DESC;
GO

-- 7.4 Subquery with EXISTS
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.ContactName
FROM Customers c
WHERE EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.CustomerID = c.CustomerID
        AND YEAR(o.OrderDate) = 2024
        AND o.OrderStatus = 'Delivered'
);  -- Customers with delivered orders in 2024
GO

-- 7.5 Subquery with NOT EXISTS
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category
FROM Products p
WHERE NOT EXISTS (
    SELECT 1
    FROM OrderDetails od
    WHERE od.ProductID = p.ProductID
);  -- Products never ordered
GO

-- 7.6 Subquery with IN
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.JobTitle
FROM Employees e
WHERE e.DepartmentID IN (
    SELECT d.DepartmentID
    FROM Departments d
    WHERE d.Budget > 400000
);  -- Employees in departments with budget > 400k
GO

-- 7.7 Common Table Expression (CTE) - Basic
WITH HighValueOrders AS (
    SELECT 
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        SUM(od.LineTotal) AS OrderTotal
    FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY o.OrderID, o.CustomerID, o.OrderDate
    HAVING SUM(od.LineTotal) > 5000
)
SELECT 
    hvo.OrderID,
    c.CompanyName,
    hvo.OrderDate,
    hvo.OrderTotal
FROM HighValueOrders hvo
INNER JOIN Customers c ON hvo.CustomerID = c.CustomerID
ORDER BY hvo.OrderTotal DESC;
GO

-- 7.8 Multiple CTEs
WITH 
CustomerOrders AS (
    SELECT 
        c.CustomerID,
        c.CompanyName,
        c.Country,
        COUNT(o.OrderID) AS OrderCount,
        SUM(o.Freight) AS TotalFreight
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID
