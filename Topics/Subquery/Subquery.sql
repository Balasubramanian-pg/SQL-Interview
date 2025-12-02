```sql
/*
================================================================================
COMPREHENSIVE SQL SUBQUERY TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to SQL Subqueries with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- Subqueries = Queries nested inside other queries
-- Focus: Correlated vs non-correlated, types, optimization
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SubqueryTutorialDB')
BEGIN
    ALTER DATABASE SubqueryTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SubqueryTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE SubqueryTutorialDB;
GO

USE SubqueryTutorialDB;
GO

-- Enable statistics for query optimization
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create comprehensive sample database schema
-- Multi-table relational design for complex subquery scenarios
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
    PerformanceRating INT CHECK (PerformanceRating BETWEEN 1 AND 5),
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

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode AS ('CUST' + RIGHT('0000' + CAST(CustomerID AS VARCHAR(4)), 4)) PERSISTED,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    City NVARCHAR(50),
    Country NVARCHAR(50) DEFAULT 'USA',
    Phone VARCHAR(20),
    Email NVARCHAR(100),
    CustomerType VARCHAR(20) DEFAULT 'Retail'
        CHECK (CustomerType IN ('Retail', 'Wholesale', 'Corporate', 'Government')),
    CreditLimit DECIMAL(15,2) DEFAULT 5000.00,
    CustomerSince DATE DEFAULT GETDATE(),
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
    Freight DECIMAL(10,2) DEFAULT 0.00,
    OrderStatus VARCHAR(20) DEFAULT 'Pending'
        CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'On Hold')),
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

-- Create SalesTargets table for correlated subquery examples
CREATE TABLE SalesTargets (
    TargetID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL CHECK (Quarter BETWEEN 1 AND 4),
    TargetAmount DECIMAL(15,2) NOT NULL,
    ActualAmount DECIMAL(15,2) DEFAULT 0.00,
    -- Foreign key
    CONSTRAINT FK_SalesTargets_Employees FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID),
    -- Check constraints
    CONSTRAINT CHK_SalesTargets_Amount CHECK (TargetAmount > 0),
    CONSTRAINT UQ_SalesTargets_Employee_Year_Quarter UNIQUE (EmployeeID, Year, Quarter)
);
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

INSERT INTO Employees (FirstName, LastName, Email, Phone, HireDate, JobTitle, Salary, DepartmentID, PerformanceRating)
VALUES 
    ('John', 'Smith', 'john.smith@company.com', '555-0101', '2020-03-15', 'Sales Manager', 85000.00, 1, 4),
    ('Maria', 'Garcia', 'maria.garcia@company.com', '555-0102', '2021-06-01', 'Sales Representative', 65000.00, 1, 5),
    ('David', 'Chen', 'david.chen@company.com', '555-0103', '2019-11-22', 'Marketing Director', 95000.00, 2, 4),
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', '555-0104', '2022-01-10', 'Marketing Specialist', 55000.00, 2, 3),
    ('Michael', 'Brown', 'michael.brown@company.com', '555-0105', '2018-07-30', 'IT Manager', 105000.00, 3, 5),
    ('Emily', 'Wilson', 'emily.wilson@company.com', '555-0106', '2023-03-01', 'Software Developer', 85000.00, 3, 4),
    ('Robert', 'Taylor', 'robert.taylor@company.com', '555-0107', '2020-09-15', 'Financial Analyst', 75000.00, 4, 4),
    ('Jennifer', 'Lee', 'jennifer.lee@company.com', '555-0108', '2021-12-05', 'HR Manager', 80000.00, 5, 5);
GO

UPDATE Departments SET ManagerID = 1 WHERE DepartmentID = 1;
UPDATE Departments SET ManagerID = 3 WHERE DepartmentID = 2;
UPDATE Departments SET ManagerID = 5 WHERE DepartmentID = 3;
UPDATE Departments SET ManagerID = 7 WHERE DepartmentID = 4;
UPDATE Departments SET ManagerID = 8 WHERE DepartmentID = 5;

UPDATE Employees SET ManagerID = 1 WHERE EmployeeID IN (2);
UPDATE Employees SET ManagerID = 3 WHERE EmployeeID IN (4);
UPDATE Employees SET ManagerID = 5 WHERE EmployeeID IN (6);
GO

INSERT INTO Customers (CompanyName, ContactName, City, Country, Phone, Email, CustomerType, CreditLimit)
VALUES 
    ('Acme Corp', 'John Doe', 'New York', 'USA', '212-555-0101', 'acme@example.com', 'Corporate', 50000.00),
    ('Global Tech', 'Jane Smith', 'London', 'UK', '44-20-5555-0102', 'global@example.com', 'Corporate', 75000.00),
    ('City Retail', 'Bob Wilson', 'Chicago', 'USA', '312-555-0103', 'city@example.com', 'Retail', 15000.00),
    ('Office Supplies Inc', 'Alice Brown', 'Toronto', 'Canada', '416-555-0104', 'office@example.com', 'Wholesale', 30000.00),
    ('Tech Solutions', 'Charlie Davis', 'San Francisco', 'USA', '415-555-0105', 'tech@example.com', 'Corporate', 100000.00),
    ('Quick Mart', 'Eva Green', 'Los Angeles', 'USA', '213-555-0106', 'quick@example.com', 'Retail', 10000.00),
    ('Premium Goods', 'Frank White', 'Miami', 'USA', '305-555-0107', 'premium@example.com', 'Retail', 20000.00),
    ('Global Importers', 'Grace Lee', 'Tokyo', 'Japan', '81-3-5555-0108', 'import@example.com', 'Wholesale', 60000.00);
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
    ('Monitor 27"', 'Electronics', 'Displays', 349.99, 200.00, 40),
    ('Printer', 'Electronics', 'Office', 199.99, 120.00, 60),
    ('Desk', 'Furniture', 'Tables', 499.99, 300.00, 20);
GO

INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, Freight, OrderStatus, PaymentStatus)
VALUES 
    (1, 2, '2024-01-15', '2024-01-25', '2024-01-20', 25.00, 'Delivered', 'Paid'),
    (2, 2, '2024-02-01', '2024-02-10', '2024-02-05', 45.00, 'Delivered', 'Paid'),
    (3, 4, '2024-02-15', '2024-02-28', '2024-02-20', 15.00, 'Delivered', 'Paid'),
    (1, 2, '2024-03-01', '2024-03-10', NULL, 30.00, 'Processing', 'Pending'),
    (4, 6, '2024-03-05', '2024-03-15', '2024-03-10', 20.00, 'Shipped', 'Pending'),
    (5, 2, '2024-03-10', '2024-03-20', NULL, 50.00, 'Pending', 'Unpaid'),
    (6, 2, '2024-01-20', '2024-01-30', '2024-01-25', 10.00, 'Delivered', 'Paid'),
    (7, 4, '2024-02-10', '2024-02-20', '2024-02-15', 12.00, 'Delivered', 'Paid'),
    (8, 2, '2024-03-15', '2024-03-25', NULL, 60.00, 'Processing', 'Pending');
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
    (6, 8, 349.99, 8, 12.00),
    (7, 9, 199.99, 3, 5.00),
    (8, 10, 499.99, 2, 10.00),
    (9, 1, 1299.99, 1, 0.00),
    (9, 7, 799.99, 2, 5.00);
GO

INSERT INTO SalesTargets (EmployeeID, Year, Quarter, TargetAmount, ActualAmount)
VALUES 
    (2, 2024, 1, 50000.00, 45000.00),
    (2, 2024, 2, 55000.00, 0.00),
    (4, 2024, 1, 30000.00, 28000.00),
    (4, 2024, 2, 32000.00, 0.00),
    (6, 2024, 1, 40000.00, 42000.00),
    (6, 2024, 2, 45000.00, 0.00);
GO

-- Create indexes for performance
CREATE INDEX IX_Employees_DepartmentID ON Employees(DepartmentID);
CREATE INDEX IX_Employees_Salary ON Employees(Salary);
CREATE INDEX IX_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX IX_Orders_EmployeeID ON Orders(EmployeeID);
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX IX_Products_Category ON Products(Category);
CREATE INDEX IX_Products_UnitPrice ON Products(UnitPrice);
CREATE INDEX IX_Customers_CreditLimit ON Customers(CreditLimit);
CREATE INDEX IX_OrderDetails_ProductID ON OrderDetails(ProductID);
GO

-- Section 2: Fundamental Concepts - Scalar Subqueries
--------------------------------------------------------------------
-- Subqueries that return a single value
-- Used in SELECT, WHERE, and HAVING clauses
--------------------------------------------------------------------

PRINT '=== SECTION 2: SCALAR SUBQUERIES ===';

-- 2.1 Scalar subquery in SELECT clause
-- Returns company average salary for comparison
SELECT 
    EmployeeID,
    FullName,
    Salary,
    (SELECT AVG(Salary) FROM Employees WHERE IsActive = 1) AS CompanyAvgSalary,
    Salary - (SELECT AVG(Salary) FROM Employees WHERE IsActive = 1) AS DifferenceFromAvg
FROM Employees
WHERE IsActive = 1
ORDER BY DifferenceFromAvg DESC;
GO

-- 2.2 Multiple scalar subqueries in SELECT
-- Compare with department and company averages
SELECT 
    e.EmployeeID,
    e.FullName,
    e.Salary,
    d.DepartmentName,
    (SELECT AVG(Salary) FROM Employees WHERE DepartmentID = e.DepartmentID) AS DeptAvgSalary,
    (SELECT AVG(Salary) FROM Employees WHERE IsActive = 1) AS CompanyAvgSalary,
    e.Salary - (SELECT AVG(Salary) FROM Employees WHERE DepartmentID = e.DepartmentID) AS DiffFromDeptAvg
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.IsActive = 1
ORDER BY d.DepartmentName, e.Salary DESC;
GO

-- 2.3 Scalar subquery in WHERE clause (comparison)
-- Find employees earning more than company average
SELECT 
    EmployeeID,
    FullName,
    Salary,
    JobTitle
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees WHERE IsActive = 1)
    AND IsActive = 1
ORDER BY Salary DESC;
GO

-- 2.4 Scalar subquery with aggregate in WHERE
-- Find departments with above-average budget
SELECT 
    DepartmentID,
    DepartmentName,
    Budget,
    (SELECT AVG(Budget) FROM Departments WHERE IsActive = 1) AS AvgDepartmentBudget
FROM Departments
WHERE Budget > (SELECT AVG(Budget) FROM Departments WHERE IsActive = 1)
    AND IsActive = 1
ORDER BY Budget DESC;
GO

-- 2.5 Scalar subquery with MAX()
-- Find the most expensive product
SELECT 
    ProductID,
    ProductName,
    UnitPrice,
    Category
FROM Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products WHERE IsActive = 1)
    AND IsActive = 1;
GO

-- 2.6 Scalar subquery with COUNT()
-- Find departments with more than 2 employees
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    (SELECT COUNT(*) FROM Employees WHERE DepartmentID = d.DepartmentID AND IsActive = 1) AS EmployeeCount
FROM Departments d
WHERE (SELECT COUNT(*) FROM Employees WHERE DepartmentID = d.DepartmentID AND IsActive = 1) > 2
    AND d.IsActive = 1
ORDER BY EmployeeCount DESC;
GO

-- 2.7 Scalar subquery with mathematical operations
-- Find products priced above average by at least 50%
SELECT 
    ProductID,
    ProductName,
    UnitPrice,
    (SELECT AVG(UnitPrice) FROM Products WHERE IsActive = 1) AS AvgPrice,
    UnitPrice / (SELECT AVG(UnitPrice) FROM Products WHERE IsActive = 1) * 100 AS PercentOfAvg
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products WHERE IsActive = 1) * 1.5
    AND IsActive = 1
ORDER BY UnitPrice DESC;
GO

-- Section 3: Core Functionality - Column Subqueries
--------------------------------------------------------------------
-- Subqueries that return a single column with multiple rows
-- Used with IN, NOT IN, ANY, ALL operators
--------------------------------------------------------------------

PRINT '=== SECTION 3: COLUMN SUBQUERIES ===';

-- 3.1 Subquery with IN operator
-- Find employees in departments with budget > 400000
SELECT 
    e.EmployeeID,
    e.FullName,
    e.JobTitle,
    d.DepartmentName,
    d.Budget
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.DepartmentID IN (
    SELECT DepartmentID 
    FROM Departments 
    WHERE Budget > 400000
        AND IsActive = 1
)
AND e.IsActive = 1
ORDER BY d.DepartmentName, e.FullName;
GO

-- 3.2 Subquery with NOT IN operator
-- Find customers who haven't placed orders
SELECT 
    CustomerID,
    CompanyName,
    ContactName,
    City,
    CustomerSince
FROM Customers
WHERE CustomerID NOT IN (
    SELECT DISTINCT CustomerID 
    FROM Orders 
    WHERE OrderStatus NOT IN ('Cancelled')
)
AND IsActive = 1
ORDER BY CustomerSince DESC;
GO

-- 3.3 Subquery with multiple values in IN
-- Find products in specific categories
SELECT 
    ProductID,
    ProductName,
    Category,
    UnitPrice
FROM Products
WHERE Category IN (
    SELECT DISTINCT Category 
    FROM Products 
    WHERE UnitPrice > 500
        AND IsActive = 1
)
AND IsActive = 1
ORDER BY Category, UnitPrice DESC;
GO

-- 3.4 Subquery with ANY/SOME operator
-- Find employees earning more than any IT department employee
SELECT 
    e.EmployeeID,
    e.FullName,
    e.Salary,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > ANY (
    SELECT Salary 
    FROM Employees 
    WHERE DepartmentID = 3  -- IT department
        AND IsActive = 1
)
AND e.IsActive = 1
ORDER BY e.Salary DESC;
GO

-- 3.5 Subquery with ALL operator
-- Find employees earning more than all Marketing department employees
SELECT 
    e.EmployeeID,
    e.FullName,
    e.Salary,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > ALL (
    SELECT Salary 
    FROM Employees 
    WHERE DepartmentID = 2  -- Marketing department
        AND IsActive = 1
)
AND e.IsActive = 1
ORDER BY e.Salary DESC;
GO

-- 3.6 Subquery with EXISTS demonstration (preview)
-- Find departments that have employees
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    d.Location
FROM Departments d
WHERE EXISTS (
    SELECT 1 
    FROM Employees e 
    WHERE e.DepartmentID = d.DepartmentID 
        AND e.IsActive = 1
)
AND d.IsActive = 1
ORDER BY d.DepartmentName;
GO

-- Section 4: Core Functionality - Correlated Subqueries
--------------------------------------------------------------------
-- Subqueries that reference columns from the outer query
-- Executed once for each row in outer query
--------------------------------------------------------------------

PRINT '=== SECTION 4: CORRELATED SUBQUERIES ===';

-- 4.1 Basic correlated subquery
-- Find employees earning more than their department average
SELECT 
    e1.EmployeeID,
    e1.FullName,
    e1.Salary,
    d.DepartmentName,
    (SELECT AVG(e2.Salary) 
     FROM Employees e2 
     WHERE e2.DepartmentID = e1.DepartmentID 
        AND e2.IsActive = 1) AS DeptAvgSalary
FROM Employees e1
INNER JOIN Departments d ON e1.DepartmentID = d.DepartmentID
WHERE e1.Salary > (
    SELECT AVG(e2.Salary) 
    FROM Employees e2 
    WHERE e2.DepartmentID = e1.DepartmentID 
        AND e2.IsActive = 1
)
AND e1.IsActive = 1
ORDER BY d.DepartmentName, e1.Salary DESC;
GO

-- 4.2 Correlated subquery with multiple conditions
-- Find customers who placed orders in the last 30 days
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.ContactName,
    c.City,
    (SELECT MAX(o.OrderDate) 
     FROM Orders o 
     WHERE o.CustomerID = c.CustomerID) AS LastOrderDate
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID 
        AND o.OrderDate >= DATEADD(DAY, -30, GETDATE())
)
AND c.IsActive = 1
ORDER BY LastOrderDate DESC;
GO

-- 4.3 Correlated subquery with aggregation
-- Find products with above-average sales in their category
SELECT 
    p1.ProductID,
    p1.ProductName,
    p1.Category,
    p1.UnitPrice,
    (SELECT AVG(p2.UnitPrice) 
     FROM Products p2 
     WHERE p2.Category = p1.Category 
        AND p2.IsActive = 1) AS CategoryAvgPrice,
    (SELECT SUM(od.Quantity) 
     FROM OrderDetails od
     INNER JOIN Orders o ON od.OrderID = o.OrderID
     WHERE od.ProductID = p1.ProductID 
        AND o.OrderStatus = 'Delivered') AS TotalSold
FROM Products p1
WHERE p1.UnitPrice > (
    SELECT AVG(p2.UnitPrice) 
    FROM Products p2 
    WHERE p2.Category = p1.Category 
        AND p2.IsActive = 1
)
AND p1.IsActive = 1
ORDER BY p1.Category, p1.UnitPrice DESC;
GO

-- 4.4 Correlated subquery in HAVING clause
-- Find departments where average salary is above company average
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    AVG(e.Salary) AS DeptAvgSalary,
    (SELECT AVG(Salary) FROM Employees WHERE IsActive = 1) AS CompanyAvgSalary
FROM Departments d
INNER JOIN Employees e ON d.DepartmentID = e.DepartmentID
WHERE e.IsActive = 1
    AND d.IsActive = 1
GROUP BY d.DepartmentID, d.DepartmentName
HAVING AVG(e.Salary) > (
    SELECT AVG(Salary) 
    FROM Employees 
    WHERE IsActive = 1
)
ORDER BY DeptAvgSalary DESC;
GO

-- 4.5 Nested correlated subqueries
-- Find employees who are top earners in their department
SELECT 
    e1.EmployeeID,
    e1.FullName,
    e1.Salary,
    d.DepartmentName,
    e1.Salary - (
        SELECT AVG(e2.Salary) 
        FROM Employees e2 
        WHERE e2.DepartmentID = e1.DepartmentID
            AND e2.IsActive = 1
    ) AS AboveDeptAvg
FROM Employees e1
INNER JOIN Departments d ON e1.DepartmentID = d.DepartmentID
WHERE e1.Salary = (
    SELECT MAX(e3.Salary) 
    FROM Employees e3 
    WHERE e3.DepartmentID = e1.DepartmentID
        AND e3.IsActive = 1
)
AND e1.IsActive = 1
ORDER BY e1.Salary DESC;
GO

-- Section 5: Intermediate Techniques - EXISTS and NOT EXISTS
--------------------------------------------------------------------
-- Using EXISTS for efficient existence checks
-- Often more efficient than IN for large datasets
--------------------------------------------------------------------

PRINT '=== SECTION 5: EXISTS AND NOT EXISTS ===';

-- 5.1 EXISTS - Find customers with orders
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.ContactName,
    c.City,
    c.Country
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID 
        AND o.OrderStatus = 'Delivered'
)
AND c.IsActive = 1
ORDER BY c.CompanyName;
GO

-- 5.2 NOT EXISTS - Find products never ordered
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    p.UnitPrice,
    p.QuantityInStock
FROM Products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM OrderDetails od 
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE od.ProductID = p.ProductID 
        AND o.OrderStatus NOT IN ('Cancelled')
)
AND p.IsActive = 1
ORDER BY p.Category, p.ProductName;
GO

-- 5.3 EXISTS with multiple conditions
-- Find employees who have sold high-value orders (> $5000)
SELECT 
    e.EmployeeID,
    e.FullName,
    e.JobTitle,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.EmployeeID = e.EmployeeID 
        AND o.OrderStatus = 'Delivered'
    GROUP BY o.OrderID
    HAVING SUM(od.LineTotal) > 5000
)
AND e.IsActive = 1
ORDER BY e.FullName;
GO

-- 5.4 NOT EXISTS for hierarchical checks
-- Find employees who don't manage anyone
SELECT 
    e.EmployeeID,
    e.FullName,
    e.JobTitle,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE NOT EXISTS (
    SELECT 1 
    FROM Employees e2 
    WHERE e2.ManagerID = e.EmployeeID 
        AND e2.IsActive = 1
)
AND e.IsActive = 1
ORDER BY d.DepartmentName, e.FullName;
GO

-- 5.5 EXISTS with correlated subquery for date range
-- Find customers with orders in both Q1 and Q2 2024
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.ContactName
FROM Customers c
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID 
        AND o.OrderStatus = 'Delivered'
        AND o.OrderDate BETWEEN '2024-01-01' AND '2024-03-31'
)
AND EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.CustomerID = c.CustomerID 
        AND o.OrderStatus = 'Delivered'
        AND o.OrderDate BETWEEN '2024-04-01' AND '2024-06-30'
)
AND c.IsActive = 1;
GO

-- 5.6 Performance comparison: EXISTS vs IN
-- Example 1: EXISTS approach
SELECT 
    e.EmployeeID,
    e.FullName
FROM Employees e
WHERE EXISTS (
    SELECT 1 
    FROM Orders o 
    WHERE o.EmployeeID = e.EmployeeID 
        AND o.OrderStatus = 'Delivered'
);
GO

-- Example 2: IN approach (may be less efficient)
SELECT 
    e.EmployeeID,
    e.FullName
FROM Employees e
WHERE e.EmployeeID IN (
    SELECT DISTINCT EmployeeID 
    FROM Orders 
    WHERE OrderStatus = 'Delivered'
);
GO

-- Section 6: Intermediate Techniques - Derived Tables (Inline Views)
--------------------------------------------------------------------
-- Subqueries in FROM clause that act as temporary tables
--------------------------------------------------------------------

PRINT '=== SECTION 6: DERIVED TABLES ===';

-- 6.1 Basic derived table
-- Calculate department statistics
SELECT 
    dept_stats.DepartmentName,
    dept_stats.EmployeeCount,
    dept_stats.AvgSalary,
    dept_stats.TotalSalary
FROM (
    SELECT 
        d.DepartmentName,
        COUNT(e.EmployeeID) AS EmployeeCount,
        AVG(e.Salary) AS AvgSalary,
        SUM(e.Salary) AS TotalSalary
    FROM Departments d
    LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
    WHERE d.IsActive = 1
    GROUP BY d.DepartmentName
) AS dept_stats
WHERE dept_stats.EmployeeCount > 0
ORDER BY dept_stats.AvgSalary DESC;
GO

-- 6.2 Derived table with joins
-- Analyze product sales performance
SELECT 
    p.ProductName,
    p.Category,
    p.UnitPrice,
    sales.TotalQuantitySold,
    sales.TotalRevenue,
    sales.AverageDiscount
FROM Products p
INNER JOIN (
    SELECT 
        od.ProductID,
        SUM(od.Quantity) AS TotalQuantitySold,
        SUM(od.LineTotal) AS TotalRevenue,
        AVG(od.Discount) AS AverageDiscount
    FROM OrderDetails od
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE o.OrderStatus = 'Delivered'
    GROUP BY od.ProductID
) AS sales ON p.ProductID = sales.ProductID
WHERE p.IsActive = 1
ORDER BY sales.TotalRevenue DESC;
GO

-- 6.3 Derived table with window functions
-- Rank employees within departments
SELECT 
    dept_ranks.DepartmentName,
    dept_ranks.FullName,
    dept_ranks.Salary,
    dept_ranks.SalaryRank,
    dept_ranks.DepartmentAvgSalary
FROM (
    SELECT 
        d.DepartmentName,
        e.FullName,
        e.Salary,
        AVG(e.Salary) OVER (PARTITION BY d.DepartmentID) AS DepartmentAvgSalary,
        RANK() OVER (PARTITION BY d.DepartmentID ORDER BY e.Salary DESC) AS SalaryRank
    FROM Employees e
    INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1
        AND d.IsActive = 1
) AS dept_ranks
WHERE dept_ranks.SalaryRank <= 3  -- Top 3 earners in each department
ORDER BY dept_ranks.DepartmentName, dept_ranks.SalaryRank;
GO

-- 6.4 Multiple derived tables
-- Compare actual sales vs targets
SELECT 
    emp.FullName,
    emp.DepartmentName,
    COALESCE(sales.TotalSales, 0) AS ActualSales,
    COALESCE(targets.TargetAmount, 0) AS SalesTarget,
    CASE 
        WHEN COALESCE(targets.TargetAmount, 0) = 0 THEN NULL
        ELSE (COALESCE(sales.TotalSales, 0) * 100.0 / targets.TargetAmount)
    END AS TargetAchievementPercent
FROM (
    SELECT e.EmployeeID, e.FullName, d.DepartmentName
    FROM Employees e
    INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1
        AND d.DepartmentName = 'Sales'
) AS emp
LEFT JOIN (
    SELECT 
        o.EmployeeID,
        SUM(od.LineTotal) AS TotalSales
    FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.OrderStatus = 'Delivered'
        AND YEAR(o.OrderDate) = 2024
        AND MONTH(o.OrderDate) BETWEEN 1 AND 3
    GROUP BY o.EmployeeID
) AS sales ON emp.EmployeeID = sales.EmployeeID
LEFT JOIN (
    SELECT 
        EmployeeID,
        SUM(TargetAmount) AS TargetAmount
    FROM SalesTargets
    WHERE Year = 2024
        AND Quarter = 1
    GROUP
