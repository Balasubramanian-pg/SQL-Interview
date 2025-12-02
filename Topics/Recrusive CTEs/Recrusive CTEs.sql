/*
================================================================================
COMPREHENSIVE SQL RECURSIVE FUNCTIONS TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to Recursive Queries and Functions with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- Recursive functions: CTEs, hierarchies, graphs, and complex data relationships
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'RecursiveTutorialDB')
BEGIN
    ALTER DATABASE RecursiveTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RecursiveTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE RecursiveTutorialDB;
GO

USE RecursiveTutorialDB;
GO

-- Enable MAXRECURSION option for deep recursions
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max recursion', 1000;
RECONFIGURE;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create hierarchical data structures for recursion examples
--------------------------------------------------------------------

-- 1.1 Create Employees table with hierarchical structure
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    JobTitle NVARCHAR(100),
    ManagerID INT NULL,
    Department VARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE DEFAULT GETDATE(),
    Level INT DEFAULT 1,
    PathHierarchy HIERARCHYID NULL,  -- For SQL Server hierarchyid type
    IsActive BIT DEFAULT 1,
    -- Foreign key for self-referencing relationship
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID)
        REFERENCES Employees(EmployeeID),
    -- Check constraints
    CONSTRAINT CHK_Employees_Salary CHECK (Salary > 0)
);
GO

-- 1.2 Create Categories table for nested categories
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL,
    Description NVARCHAR(500),
    SortOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    -- Foreign key for self-referencing
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryID)
        REFERENCES Categories(CategoryID),
    -- Ensure no cycles (will be enforced by application logic)
    CONSTRAINT CHK_Categories_NotSelf CHECK (CategoryID != ParentCategoryID)
);
GO

-- 1.3 Create BillOfMaterials table for product assembly
CREATE TABLE BillOfMaterials (
    BOMID INT IDENTITY(1,1) PRIMARY KEY,
    ParentProductID INT NOT NULL,
    ComponentProductID INT NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL,
    UnitOfMeasure VARCHAR(20) DEFAULT 'Each',
    Level INT DEFAULT 0,
    IsOptional BIT DEFAULT 0,
    EffectiveDate DATE DEFAULT GETDATE(),
    ExpirationDate DATE NULL,
    -- Check constraints
    CONSTRAINT CHK_BOM_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_BOM_Dates CHECK (EffectiveDate <= ISNULL(ExpirationDate, '9999-12-31')),
    CONSTRAINT UQ_BOM_Components UNIQUE (ParentProductID, ComponentProductID, EffectiveDate)
);
GO

-- 1.4 Create Products table for BOM relationships
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode VARCHAR(50) UNIQUE NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT NULL,
    UnitPrice DECIMAL(10,2),
    Cost DECIMAL(10,2),
    QuantityInStock INT DEFAULT 0,
    IsAssembly BIT DEFAULT 0,  -- Indicates if product is an assembly
    -- Foreign key
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),
    -- Check constraints
    CONSTRAINT CHK_Products_Price CHECK (UnitPrice >= 0),
    CONSTRAINT CHK_Products_Cost CHECK (Cost >= 0)
);
GO

-- Add foreign keys to BillOfMaterials
ALTER TABLE BillOfMaterials
ADD CONSTRAINT FK_BOM_ParentProduct FOREIGN KEY (ParentProductID)
    REFERENCES Products(ProductID);

ALTER TABLE BillOfMaterials
ADD CONSTRAINT FK_BOM_ComponentProduct FOREIGN KEY (ComponentProductID)
    REFERENCES Products(ProductID);
GO

-- 1.5 Create Organization chart table
CREATE TABLE OrganizationChart (
    NodeID INT IDENTITY(1,1) PRIMARY KEY,
    NodeName NVARCHAR(100) NOT NULL,
    ParentNodeID INT NULL,
    NodeType VARCHAR(50),
    EmployeeCount INT DEFAULT 0,
    Budget DECIMAL(15,2),
    Level INT DEFAULT 0,
    LeftValue INT,  -- For nested set model
    RightValue INT, -- For nested set model
    -- Foreign key
    CONSTRAINT FK_OrgChart_Parent FOREIGN KEY (ParentNodeID)
        REFERENCES OrganizationChart(NodeID)
);
GO

-- 1.6 Create FileSystem table for folder structure
CREATE TABLE FileSystem (
    FileID INT IDENTITY(1,1) PRIMARY KEY,
    FileName NVARCHAR(255) NOT NULL,
    ParentFileID INT NULL,
    IsFolder BIT DEFAULT 0,
    FileSize BIGINT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    FileType VARCHAR(50),
    -- Foreign key
    CONSTRAINT FK_FileSystem_Parent FOREIGN KEY (ParentFileID)
        REFERENCES FileSystem(FileID),
    -- Check constraints
    CONSTRAINT CHK_FileSystem_Size CHECK (FileSize >= 0)
);
GO

-- 1.7 Create Graph table for social networks
CREATE TABLE SocialNetwork (
    PersonID INT IDENTITY(1,1) PRIMARY KEY,
    PersonName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100)
);
GO

CREATE TABLE Connections (
    ConnectionID INT IDENTITY(1,1) PRIMARY KEY,
    PersonID INT NOT NULL,
    FriendID INT NOT NULL,
    ConnectionType VARCHAR(50),
    ConnectionDate DATE DEFAULT GETDATE(),
    Strength INT DEFAULT 1 CHECK (Strength BETWEEN 1 AND 10),
    -- Foreign keys
    CONSTRAINT FK_Connections_Person FOREIGN KEY (PersonID)
        REFERENCES SocialNetwork(PersonID),
    CONSTRAINT FK_Connections_Friend FOREIGN KEY (FriendID)
        REFERENCES SocialNetwork(PersonID),
    -- Ensure no self-connections
    CONSTRAINT CHK_Connections_NotSelf CHECK (PersonID != FriendID),
    -- Ensure unique connections
    CONSTRAINT UQ_Connections_Unique UNIQUE (PersonID, FriendID)
);
GO

-- Insert sample data
PRINT 'Inserting sample data...';

-- Insert Employees (hierarchical data)
INSERT INTO Employees (FirstName, LastName, JobTitle, ManagerID, Department, Salary, HireDate) VALUES
    ('John', 'CEO', 'Chief Executive Officer', NULL, 'Executive', 250000.00, '2010-01-15'),
    ('Sarah', 'COO', 'Chief Operating Officer', 1, 'Executive', 200000.00, '2012-03-20'),
    ('Michael', 'CTO', 'Chief Technology Officer', 1, 'Executive', 220000.00, '2011-06-10'),
    ('David', 'VP Sales', 'VP of Sales', 2, 'Sales', 180000.00, '2013-09-15'),
    ('Lisa', 'Sales Manager', 'Sales Manager', 4, 'Sales', 120000.00, '2015-02-28'),
    ('Robert', 'Account Exec', 'Account Executive', 5, 'Sales', 85000.00, '2018-05-10'),
    ('Jennifer', 'Account Exec', 'Account Executive', 5, 'Sales', 82000.00, '2019-03-15'),
    ('Thomas', 'VP Engineering', 'VP of Engineering', 3, 'Engineering', 190000.00, '2014-08-22'),
    ('Emily', 'Dev Manager', 'Development Manager', 8, 'Engineering', 140000.00, '2016-11-30'),
    ('Brian', 'Senior Developer', 'Senior Software Developer', 9, 'Engineering', 110000.00, '2017-04-05'),
    ('Jessica', 'Developer', 'Software Developer', 9, 'Engineering', 95000.00, '2019-08-14'),
    ('Kevin', 'Junior Developer', 'Junior Developer', 9, 'Engineering', 75000.00, '2020-01-20'),
    ('Amanda', 'HR Director', 'HR Director', 2, 'HR', 130000.00, '2015-07-12'),
    ('Chris', 'Recruiter', 'Technical Recruiter', 13, 'HR', 70000.00, '2018-09-05');
GO

-- Update hierarchyid column
UPDATE Employees SET Level = 1 WHERE ManagerID IS NULL;

-- Insert Categories (nested categories)
INSERT INTO Categories (CategoryName, ParentCategoryID, Description, SortOrder) VALUES
    ('Electronics', NULL, 'All electronic devices', 1),
    ('Computers', 1, 'Desktop and laptop computers', 1),
    ('Laptops', 2, 'Portable computers', 1),
    ('Gaming Laptops', 3, 'High-performance gaming laptops', 1),
    ('Business Laptops', 3, 'Laptops for business use', 2),
    ('Desktops', 2, 'Desktop computers', 2),
    ('Components', 1, 'Computer components', 2),
    ('Processors', 7, 'CPU processors', 1),
    ('Memory', 7, 'RAM memory', 2),
    ('Storage', 7, 'Hard drives and SSDs', 3),
    ('Home Appliances', NULL, 'Home and kitchen appliances', 2),
    ('Kitchen', 11, 'Kitchen appliances', 1),
    ('Refrigerators', 12, 'Refrigerators and freezers', 1),
    ('Microwaves', 12, 'Microwave ovens', 2);
GO

-- Insert Products
INSERT INTO Products (ProductCode, ProductName, CategoryID, UnitPrice, Cost, IsAssembly) VALUES
    ('LAPTOP001', 'Gaming Laptop Pro', 4, 1999.99, 1200.00, 1),
    ('LAPTOP002', 'Business Elite', 5, 1499.99, 900.00, 1),
    ('DESK001', 'Workstation Desktop', 6, 2499.99, 1500.00, 1),
    ('CPU001', 'Intel i9 Processor', 8, 499.99, 300.00, 0),
    ('CPU002', 'AMD Ryzen 9', 8, 449.99, 280.00, 0),
    ('RAM001', '32GB DDR5 RAM', 9, 199.99, 120.00, 0),
    ('RAM002', '16GB DDR4 RAM', 9, 99.99, 60.00, 0),
    ('SSD001', '1TB NVMe SSD', 10, 129.99, 80.00, 0),
    ('HDD001', '2TB HDD', 10, 79.99, 50.00, 0),
    ('MB001', 'Gaming Motherboard', 7, 299.99, 180.00, 0),
    ('PSU001', '850W Power Supply', 7, 149.99, 90.00, 0),
    ('CASE001', 'ATX Computer Case', 7, 119.99, 70.00, 0),
    ('FAN001', 'CPU Cooler', 7, 89.99, 55.00, 0),
    ('FRIDGE001', 'Smart Refrigerator', 13, 2999.99, 1800.00, 0),
    ('MICROWAVE001', 'Convection Microwave', 14, 299.99, 180.00, 0);
GO

-- Insert Bill of Materials
INSERT INTO BillOfMaterials (ParentProductID, ComponentProductID, Quantity, Level) VALUES
    -- Gaming Laptop Pro assembly
    (1, 4, 1, 1),   -- i9 Processor
    (1, 6, 1, 1),   -- 32GB RAM
    (1, 8, 2, 1),   -- 2 x 1TB SSD
    
    -- Business Elite assembly
    (2, 5, 1, 1),   -- AMD Ryzen 9
    (2, 7, 1, 1),   -- 16GB RAM
    (2, 8, 1, 1),   -- 1TB SSD
    
    -- Workstation Desktop assembly (multi-level BOM)
    (3, 4, 1, 1),   -- i9 Processor (Level 1)
    (3, 6, 2, 1),   -- 2 x 32GB RAM (Level 1)
    (3, 8, 2, 1),   -- 2 x 1TB SSD (Level 1)
    (3, 9, 1, 1),   -- 2TB HDD (Level 1)
    (3, 10, 1, 2),  -- Motherboard (Level 2, sub-assembly)
    (3, 11, 1, 2),  -- Power Supply (Level 2)
    (3, 12, 1, 2),  -- Computer Case (Level 2)
    (3, 13, 1, 2);  -- CPU Cooler (Level 2)
GO

-- Insert Organization Chart (nested set model)
INSERT INTO OrganizationChart (NodeName, ParentNodeID, NodeType, EmployeeCount, Budget, Level, LeftValue, RightValue) VALUES
    ('CEO Office', NULL, 'Division', 1, 1000000.00, 1, 1, 28),
    ('Operations', 1, 'Department', 1, 800000.00, 2, 2, 15),
    ('Sales', 2, 'Team', 4, 500000.00, 3, 3, 8),
    ('North Region', 3, 'Unit', 2, 250000.00, 4, 4, 5),
    ('South Region', 3, 'Unit', 2, 250000.00, 4, 6, 7),
    ('Engineering', 2, 'Team', 4, 700000.00, 3, 9, 14),
    ('Development', 6, 'Unit', 3, 500000.00, 4, 10, 13),
    ('Backend', 7, 'Sub-Unit', 2, 300000.00, 5, 11, 12),
    ('HR', 1, 'Department', 2, 300000.00, 2, 16, 27),
    ('Recruitment', 9, 'Team', 1, 150000.00, 3, 17, 20),
    ('Tech Recruitment', 10, 'Unit', 1, 100000.00, 4, 18, 19),
    ('Training', 9, 'Team', 1, 150000.00, 3, 21, 26),
    ('Technical Training', 12, 'Unit', 1, 100000.00, 4, 22, 23),
    ('Soft Skills', 12, 'Unit', 1, 50000.00, 4, 24, 25);
GO

-- Insert FileSystem (folder structure)
INSERT INTO FileSystem (FileName, ParentFileID, IsFolder, FileSize, FileType) VALUES
    ('Root', NULL, 1, 0, 'Folder'),
    ('Documents', 1, 1, 0, 'Folder'),
    ('Projects', 1, 1, 0, 'Folder'),
    ('Company', 2, 1, 0, 'Folder'),
    ('Personal', 2, 1, 0, 'Folder'),
    ('Reports', 3, 1, 0, 'Folder'),
    ('SourceCode', 3, 1, 0, 'Folder'),
    ('Annual Report 2023.pdf', 4, 0, 5242880, 'PDF'),
    ('Budget Q4.xlsx', 4, 0, 1048576, 'Excel'),
    ('Vacation Photos', 5, 1, 0, 'Folder'),
    ('Resume.docx', 5, 0, 262144, 'Word'),
    ('Sales Report Q1.pdf', 6, 0, 2097152, 'PDF'),
    ('MainApp', 7, 1, 0, 'Folder'),
    ('Utils', 7, 1, 0, 'Folder'),
    ('Program.cs', 13, 0, 4096, 'C#'),
    ('Database.sql', 13, 0, 8192, 'SQL'),
    ('StringHelper.cs', 14, 0, 2048, 'C#'),
    ('Beach.jpg', 10, 0, 3145728, 'Image'),
    ('Mountain.jpg', 10, 0, 4194304, 'Image');
GO

-- Insert Social Network data
INSERT INTO SocialNetwork (PersonName, Location) VALUES
    ('Alice', 'New York'),
    ('Bob', 'San Francisco'),
    ('Charlie', 'Chicago'),
    ('Diana', 'Boston'),
    ('Eve', 'Seattle'),
    ('Frank', 'Austin'),
    ('Grace', 'Denver'),
    ('Henry', 'Miami');
GO

INSERT INTO Connections (PersonID, FriendID, ConnectionType, Strength) VALUES
    (1, 2, 'Friend', 8),
    (1, 3, 'Colleague', 6),
    (2, 4, 'Friend', 9),
    (2, 5, 'Family', 10),
    (3, 6, 'Colleague', 7),
    (4, 7, 'Friend', 8),
    (5, 8, 'Friend', 7),
    (6, 7, 'Colleague', 6),
    (7, 8, 'Friend', 9),
    (3, 1, 'Colleague', 6),  -- Reciprocal
    (4, 2, 'Friend', 9);     -- Reciprocal
GO

-- Section 2: Fundamental Concepts - Basic Recursive CTEs
--------------------------------------------------------------------
-- Introduction to Recursive Common Table Expressions (CTEs)
-- Basic hierarchy traversal
--------------------------------------------------------------------

PRINT '=== SECTION 2: BASIC RECURSIVE CTEs ===';

-- 2.1 Simple recursive CTE structure
-- Syntax: 
-- WITH RecursiveCTE AS (
--     Anchor member (initial query)
--     UNION ALL
--     Recursive member (references CTE)
-- )
-- SELECT * FROM RecursiveCTE;

WITH SimpleCount AS (
    -- Anchor member: Start with 1
    SELECT 1 AS Number
    
    UNION ALL
    
    -- Recursive member: Add 1 until 10
    SELECT Number + 1
    FROM SimpleCount
    WHERE Number < 10
)
SELECT Number
FROM SimpleCount
ORDER BY Number;
GO

-- 2.2 Generate dates using recursion
WITH DateSeries AS (
    -- Anchor: Start date
    SELECT CAST('2024-01-01' AS DATE) AS DateValue
    
    UNION ALL
    
    -- Recursive: Add one day
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateSeries
    WHERE DateValue < '2024-01-31'
)
SELECT 
    DateValue,
    DATENAME(WEEKDAY, DateValue) AS Weekday,
    DATEPART(WEEK, DateValue) AS WeekNumber
FROM DateSeries
ORDER BY DateValue;
GO

-- 2.3 Employee hierarchy - basic recursive query
WITH EmployeeHierarchy AS (
    -- Anchor: Top-level employees (CEO)
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        JobTitle,
        ManagerID,
        1 AS Level,
        CAST(FirstName + ' ' + LastName AS VARCHAR(500)) AS HierarchyPath
    FROM Employees
    WHERE ManagerID IS NULL  -- CEO has no manager
    
    UNION ALL
    
    -- Recursive: Employees reporting to managers in the CTE
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.JobTitle,
        e.ManagerID,
        eh.Level + 1 AS Level,
        CAST(eh.HierarchyPath + ' -> ' + e.FirstName + ' ' + e.LastName AS VARCHAR(500))
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    Level,
    REPLICATE('  ', Level - 1) + FirstName + ' ' + LastName AS Employee,
    JobTitle,
    HierarchyPath
FROM EmployeeHierarchy
ORDER BY HierarchyPath;
GO

-- Section 3: Core Functionality - Hierarchical Data Queries
--------------------------------------------------------------------
-- Advanced hierarchy queries with various traversal patterns
--------------------------------------------------------------------

PRINT '=== SECTION 3: HIERARCHICAL DATA QUERIES ===';

-- 3.1 Get full management chain for a specific employee
WITH ManagementChain AS (
    -- Anchor: Start with specific employee
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        JobTitle,
        ManagerID,
        0 AS LevelUp
    FROM Employees
    WHERE EmployeeID = 11  -- Jessica (Developer)
    
    UNION ALL
    
    -- Recursive: Go up the management chain
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.JobTitle,
        e.ManagerID,
        mc.LevelUp + 1
    FROM Employees e
    INNER JOIN ManagementChain mc ON e.EmployeeID = mc.ManagerID
)
SELECT 
    LevelUp,
    FirstName + ' ' + LastName AS Manager,
    JobTitle,
    CASE 
        WHEN LevelUp = 0 THEN 'Employee'
        ELSE 'Manager Level ' + CAST(LevelUp AS VARCHAR)
    END AS Relationship
FROM ManagementChain
ORDER BY LevelUp DESC;  -- Show CEO first
GO

-- 3.2 Get all subordinates under a manager (drill down)
WITH SubordinateTree AS (
    -- Anchor: Start with specific manager
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        JobTitle,
        ManagerID,
        0 AS LevelDown,
        CAST(EmployeeID AS VARCHAR(MAX)) AS EmployeePath
    FROM Employees
    WHERE EmployeeID = 9  -- Emily (Dev Manager)
    
    UNION ALL
    
    -- Recursive: Get subordinates
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.JobTitle,
        e.ManagerID,
        st.LevelDown + 1,
        CAST(st.EmployeePath + ',' + CAST(e.EmployeeID AS VARCHAR) AS VARCHAR(MAX))
    FROM Employees e
    INNER JOIN SubordinateTree st ON e.ManagerID = st.EmployeeID
)
SELECT 
    LevelDown,
    REPLICATE('  ', LevelDown) + FirstName + ' ' + LastName AS Employee,
    JobTitle,
    EmployeePath
FROM SubordinateTree
ORDER BY EmployeePath;
GO

-- 3.3 Calculate aggregated salary for each manager's organization
WITH OrgSalary AS (
    -- Anchor: All employees
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        ManagerID,
        Salary,
        EmployeeID AS TopManagerID,
        0 AS Level
    FROM Employees
    
    UNION ALL
    
    -- Recursive: Propagate manager relationship
    SELECT 
        os.EmployeeID,
        os.FirstName,
        os.LastName,
        os.ManagerID,
        os.Salary,
        e.ManagerID AS TopManagerID,
        os.Level + 1
    FROM OrgSalary os
    INNER JOIN Employees e ON os.TopManagerID = e.EmployeeID
    WHERE e.ManagerID IS NOT NULL
)
SELECT 
    m.FirstName + ' ' + m.LastName AS Manager,
    COUNT(DISTINCT os.EmployeeID) AS TotalEmployees,
    SUM(os.Salary) AS TotalOrgSalary,
    AVG(os.Salary) AS AverageSalary
FROM OrgSalary os
INNER JOIN Employees m ON os.TopManagerID = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
ORDER BY TotalOrgSalary DESC;
GO

-- 3.4 Find leaf nodes (employees with no subordinates)
WITH EmployeeHierarchy AS (
    SELECT 
        EmployeeID,
        ManagerID,
        1 AS Level
    FROM Employees
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.ManagerID,
        eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS Employee,
    e.JobTitle,
    e.Department
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1 
    FROM Employees sub 
    WHERE sub.ManagerID = e.EmployeeID
)
ORDER BY e.Department, e.LastName;
GO

-- Section 4: Intermediate Techniques - Category Hierarchies
--------------------------------------------------------------------
-- Working with nested categories and tree structures
--------------------------------------------------------------------

PRINT '=== SECTION 4: CATEGORY HIERARCHIES ===';

-- 4.1 Get full category path for each category
WITH CategoryPath AS (
    -- Anchor: Top-level categories (no parent)
    SELECT 
        CategoryID,
        CategoryName,
        ParentCategoryID,
        1 AS Level,
        CAST(CategoryName AS NVARCHAR(MAX)) AS FullPath
    FROM Categories
    WHERE ParentCategoryID IS NULL
    
    UNION ALL
    
    -- Recursive: Build path for child categories
    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.ParentCategoryID,
        cp.Level + 1,
        CAST(cp.FullPath + ' > ' + c.CategoryName AS NVARCHAR(MAX))
    FROM Categories c
    INNER JOIN CategoryPath cp ON c.ParentCategoryID = cp.CategoryID
)
SELECT 
    Level,
    REPLICATE('  ', Level - 1) + CategoryName AS Category,
    FullPath
FROM CategoryPath
ORDER BY FullPath;
GO

-- 4.2 Get all subcategories under a specific category
WITH Subcategories AS (
    -- Anchor: Start with specific category
    SELECT 
        CategoryID,
        CategoryName,
        ParentCategoryID,
        0 AS Depth
    FROM Categories
    WHERE CategoryID = 1  -- Electronics
    
    UNION ALL
    
    -- Recursive: Get all children
    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.ParentCategoryID,
        s.Depth + 1
    FROM Categories c
    INNER JOIN Subcategories s ON c.ParentCategoryID = s.CategoryID
)
SELECT 
    Depth,
    REPLICATE('  ', Depth) + CategoryName AS Category,
    CASE 
        WHEN Depth = 0 THEN 'Root Category'
        ELSE 'Subcategory Level ' + CAST(Depth AS VARCHAR)
    END AS CategoryType
FROM Subcategories
ORDER BY Depth, CategoryName;
GO

-- 4.3 Get category tree with product counts
WITH CategoryTree AS (
    -- Anchor: Top-level categories
    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.ParentCategoryID,
        1 AS Level,
        CAST(c.CategoryName AS NVARCHAR(MAX)) AS HierarchyPath
    FROM Categories c
    WHERE c.ParentCategoryID IS NULL
    
    UNION ALL
    
    -- Recursive: Child categories
    SELECT 
        c.CategoryID,
        c.CategoryName,
        c.ParentCategoryID,
        ct.Level + 1,
        CAST(ct.HierarchyPath + ' > ' + c.CategoryName AS NVARCHAR(MAX))
    FROM Categories c
    INNER JOIN CategoryTree ct ON c.ParentCategoryID = ct.CategoryID
)
SELECT 
    ct.Level,
    REPLICATE('  ', ct.Level - 1) + ct.CategoryName AS CategoryTree,
    ct.HierarchyPath,
    COUNT(p.ProductID) AS ProductCount,
    ISNULL(SUM(p.UnitPrice), 0) AS TotalValue
FROM CategoryTree ct
LEFT JOIN Products p ON ct.CategoryID = p.CategoryID
GROUP BY ct.CategoryID, ct.CategoryName, ct.Level, ct.HierarchyPath
ORDER BY ct.HierarchyPath;
GO

-- 4.4 Find leaf categories (categories with no children)
WITH CategoryRelations AS (
    SELECT 
        CategoryID,
        ParentCategoryID
    FROM Categories
    
    UNION ALL
    
    SELECT 
        cr.CategoryID,
        c.ParentCategoryID
    FROM CategoryRelations cr
    INNER JOIN Categories c ON cr.ParentCategoryID = c.CategoryID
)
SELECT 
    c.CategoryID,
    c.CategoryName,
    cp.FullPath
FROM Categories c
CROSS APPLY (
    SELECT CAST(ct.CategoryName AS NVARCHAR(MAX)) + ' > ' + c.CategoryName AS FullPath
    FROM CategoryTree ct
    WHERE ct.CategoryID = c.CategoryID
) cp
WHERE NOT EXISTS (
    SELECT 1 
    FROM Categories child 
    WHERE child.ParentCategoryID = c.CategoryID
)
ORDER BY cp.FullPath;
GO

-- Section 5: Advanced Techniques - Bill of Materials (BOM)
--------------------------------------------------------------------
-- Multi-level product assembly explosions and cost rollups
--------------------------------------------------------------------

PRINT '=== SECTION 5: BILL OF MATERIALS (BOM) ===';

-- 5.1 Explode BOM - Get all components for a product
WITH BOMExplosion AS (
    -- Anchor: Top-level product
    SELECT 
        b.ParentProductID,
        b.ComponentProductID,
        p.ProductName,
        b.Quantity,
        b.UnitOfMeasure,
        1 AS Level,
        CAST(p.ProductName AS NVARCHAR(MAX)) AS ComponentPath,
        b.Quantity AS TotalQuantity
    FROM BillOfMaterials b
    INNER JOIN Products p ON b.ComponentProductID = p.ProductID
    WHERE b.ParentProductID = 3  -- Workstation Desktop
        AND b.Level = 1
    
    UNION ALL
    
    -- Recursive: Components of components
    SELECT 
        b.ParentProductID,
        b.ComponentProductID,
        p.ProductName,
        b.Quantity,
        b.UnitOfMeasure,
        be.Level + 1,
        CAST(be.ComponentPath + ' > ' + p.ProductName AS NVARCHAR(MAX)),
        be.TotalQuantity * b.Quantity AS TotalQuantity
    FROM BillOfMaterials b
    INNER JOIN Products p ON b.ComponentProductID = p.ProductID
    INNER JOIN BOMExplosion be ON b.ParentProductID = be.ComponentProductID
)
SELECT 
    Level,
    REPLICATE('  ', Level - 1) + ProductName AS Component,
    Quantity AS UnitQuantity,
    TotalQuantity AS TotalRequired,
    UnitOfMeasure,
    ComponentPath
FROM BOMExplosion
ORDER BY Level, ProductName;
GO

-- 5.2 Calculate total cost for a product assembly
WITH ProductCost AS (
    -- Anchor: Base components (no further assembly)
    SELECT 
        p.ProductID,
        p.ProductName,
        p.Cost AS UnitCost,
        1 AS Level,
        p.IsAssembly
    FROM Products p
    WHERE p.IsAssembly = 0  -- Base components only
    
    UNION ALL
    
    -- Recursive: Calculate assembly costs
    SELECT 
        b.ParentProductID,
        p.ProductName,
        SUM(pc.UnitCost * b.Quantity) AS UnitCost,
        pc.Level + 1,
        p.IsAssembly
    FROM BillOfMaterials b
    INNER JOIN Products p ON b.ParentProductID = p.ProductID
    INNER JOIN ProductCost pc ON b.ComponentProductID = pc.ProductID
    WHERE p.IsAssembly = 1
    GROUP BY b.ParentProductID, p.ProductName, pc.Level, p.IsAssembly
)
SELECT 
    Level,
    ProductName,
    UnitCost,
    CASE 
        WHEN IsAssembly = 1 THEN 'Assembly'
        ELSE 'Component'
    END AS ProductType,
    ROW_NUMBER() OVER (ORDER BY Level, ProductName) AS CalculationOrder
FROM ProductCost
ORDER BY Level, ProductName;
GO

-- 5.3 Find products that use a specific component
WITH ComponentUsage AS (
    -- Anchor: Direct usage of component
    SELECT 
        b.ParentProductID,
        b.ComponentProductID,
        p.ProductName AS ParentProduct,
        c.ProductName AS Component,
        b.Quantity,
        1 AS Level
    FROM BillOfMaterials b
    INNER JOIN Products p ON b.ParentProductID = p.ProductID
    INNER JOIN Products c ON b.ComponentProductID = c.ProductID
    WHERE b.ComponentProductID = 8  -- 1TB SSD
    
    UNION ALL
    
    -- Recursive: Indirect usage through assemblies
    SELECT 
        b.ParentProductID,
        cu.ComponentProductID,
        p.ProductName,
        cu.Component,
        b.Quantity * cu.Quantity AS Quantity,
        cu.Level + 1
    FROM BillOfMaterials b
    INNER JOIN Products p ON b.ParentProductID = p.ProductID
    INNER JOIN ComponentUsage cu ON b.ComponentProductID = cu.ParentProductID
)
SELECT DISTINCT
    ParentProductID,
    ParentProduct,
    Component,
    SUM(Quantity) AS TotalQuantityUsed
FROM ComponentUsage
GROUP BY ParentProductID, ParentProduct, Component
ORDER BY TotalQuantityUsed DESC;
GO

-- 5.4 Validate BOM for circular references
WITH BOMCycleCheck AS (
    SELECT 
        b.ParentProductID,
        b.ComponentProductID,
        CAST(b.ParentProductID AS VARCHAR(MAX)) + ',' + 
        CAST(b.ComponentProductID AS VARCHAR(MAX)) AS Path,
        1 AS Depth
    FROM BillOfMaterials b
    
    UNION ALL
    
    SELECT 
        bcc.ParentProductID,
        b.ComponentProductID,
        bcc.Path + ',' + CAST(b.ComponentProductID AS VARCHAR(MAX)),
        bcc.Depth + 1
    FROM BOMCycleCheck bcc
    INNER JOIN BillOfMaterials b ON bcc.ComponentProductID = b.ParentProductID
    WHERE bcc.Path NOT LIKE '%' + CAST(b.ComponentProductID AS VARCHAR(MAX)) + '%'
)
SELECT 
    ParentProductID,
    ComponentProductID,
    Path,
    Depth
FROM BOMCycleCheck
WHERE ParentProductID = ComponentProductID
    OR Depth > 10  -- Safety limit
ORDER BY Depth DESC;
GO

-- Section 6: File System and Tree Structures
--------------------------------------------------------------------
-- Working with file/folder hierarchies and tree traversal
--------------------------------------------------------------------

PRINT '=== SECTION 6: FILE SYSTEM AND TREE STRUCTURES ===';

-- 6.1 Get full folder path for each file/folder
WITH FilePaths AS (
    -- Anchor: Root folders
    SELECT 
        FileID,
        FileName,
        ParentFileID,
        IsFolder,
        FileSize,
        1 AS Depth,
        CAST(FileName AS NVARCHAR(MAX)) AS FullPath
    FROM FileSystem
    WHERE ParentFileID IS NULL
    
    UNION ALL
    
    -- Recursive: Build paths for children
    SELECT 
        f.FileID,
        f.FileName,
        f.ParentFileID,
        f.IsFolder,
        f.FileSize,
        fp.Depth + 1,
        CAST(fp.FullPath + '\' + f.FileName AS NVARCHAR(MAX))
    FROM FileSystem f
    INNER JOIN FilePaths fp ON f.ParentFileID = fp.FileID
)
SELECT 
    Depth,
    CASE 
        WHEN IsFolder = 1 THEN REPLICATE('  ', Depth - 1) + '[+] ' + FileName
        ELSE REPLICATE('  ', Depth - 1) + '    ' + FileName
    END AS FileTree,
    IsFolder,
    CASE 
        WHEN FileSize > 1048576 THEN CAST(FileSize / 1048576.0 AS DECIMAL(10,2)) + ' MB'
        WHEN FileSize > 1024 THEN CAST(FileSize / 1024.0 AS DECIMAL(10,2)) + ' KB'
        ELSE CAST(FileSize AS VARCHAR) + ' bytes'
    END AS Size,
    FullPath
FROM FilePaths
ORDER BY FullPath;
GO
