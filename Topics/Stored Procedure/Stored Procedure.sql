-- ===============================================
-- STORED PROCEDURES COMPLETE TUTORIAL
-- ===============================================
-- This script teaches stored procedures from basic to advanced
-- Execute each section step by step and read the comments

-- ===============================================
-- SECTION 1: BASIC SETUP AND UNDERSTANDING
-- ===============================================

-- First, let's create a sample database and tables for our examples
USE master;  -- Switch to master database to create new database
GO

-- Create a new database for our tutorial
-- GO is a batch separator - it tells SQL Server to execute everything above it
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'StoredProcTutorial')
BEGIN
    CREATE DATABASE StoredProcTutorial;
END
GO

-- Switch to our new database
USE StoredProcTutorial;
GO

-- Create sample tables for our examples
-- This table will store customer information
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,  -- IDENTITY creates auto-incrementing numbers
    FirstName NVARCHAR(50) NOT NULL,           -- NVARCHAR supports Unicode characters
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,                -- UNIQUE constraint prevents duplicate emails
    Phone NVARCHAR(20),
    CreatedDate DATETIME2 DEFAULT GETDATE(),   -- DEFAULT sets automatic timestamp
    IsActive BIT DEFAULT 1                     -- BIT is boolean (0 or 1)
);

-- This table will store order information
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,                   -- Foreign key reference
    OrderDate DATETIME2 DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,        -- DECIMAL(10,2) = 10 digits total, 2 after decimal
    Status NVARCHAR(20) DEFAULT 'Pending',
    -- Create foreign key relationship
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Insert sample data for testing
INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0101'),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102'),
('Bob', 'Johnson', 'bob.johnson@email.com', '555-0103'),
('Alice', 'Williams', 'alice.williams@email.com', '555-0104');

INSERT INTO Orders (CustomerID, TotalAmount, Status) VALUES
(1, 150.75, 'Completed'),
(1, 89.99, 'Pending'),
(2, 299.99, 'Completed'),
(3, 45.50, 'Cancelled'),
(2, 199.95, 'Pending');
GO

-- ===============================================
-- SECTION 2: YOUR FIRST STORED PROCEDURE
-- ===============================================

-- Basic syntax explanation:
-- CREATE PROCEDURE [schema.]procedure_name
--     @parameter1 datatype,
--     @parameter2 datatype
-- AS
-- BEGIN
--     -- SQL statements here
-- END

-- Let's create our first simple stored procedure
CREATE PROCEDURE GetAllCustomers
AS
BEGIN
    -- This procedure simply returns all customers
    -- No parameters needed for this basic example
    SELECT 
        CustomerID,
        FirstName,
        LastName,
        Email,
        Phone,
        CreatedDate,
        IsActive
    FROM Customers
    WHERE IsActive = 1;  -- Only show active customers
END
GO

-- How to execute (call) a stored procedure:
-- Method 1: Using EXEC
EXEC GetAllCustomers;

-- Method 2: Using EXECUTE (same as EXEC, just longer)
EXECUTE GetAllCustomers;
GO

-- ===============================================
-- SECTION 3: STORED PROCEDURES WITH INPUT PARAMETERS
-- ===============================================

-- Parameters allow you to pass values into your stored procedure
-- Syntax: @parameter_name datatype [= default_value]

CREATE PROCEDURE GetCustomerById
    @CustomerID INT  -- Input parameter: must provide a customer ID
AS
BEGIN
    -- Validate input parameter
    IF @CustomerID IS NULL OR @CustomerID <= 0
    BEGIN
        -- RAISERROR sends an error message back to the calling application
        RAISERROR('CustomerID must be a positive integer', 16, 1);
        RETURN;  -- Exit the procedure early
    END

    -- Return customer information for the specified ID
    SELECT 
        CustomerID,
        FirstName,
        LastName,
        Email,
        Phone,
        CreatedDate,
        IsActive
    FROM Customers
    WHERE CustomerID = @CustomerID;
    
    -- Check if customer was found
    IF @@ROWCOUNT = 0  -- @@ROWCOUNT returns number of rows affected by last statement
    BEGIN
        PRINT 'No customer found with ID: ' + CAST(@CustomerID AS NVARCHAR(10));
    END
END
GO

-- Test the procedure with different parameters
EXEC GetCustomerById @CustomerID = 1;  -- Should return John Doe
EXEC GetCustomerById @CustomerID = 999; -- Should return "No customer found"
GO

-- ===============================================
-- SECTION 4: MULTIPLE PARAMETERS AND DEFAULT VALUES
-- ===============================================

-- You can have multiple parameters, some with default values
CREATE PROCEDURE SearchCustomers
    @FirstName NVARCHAR(50) = NULL,     -- Optional parameter (has default NULL)
    @LastName NVARCHAR(50) = NULL,      -- Optional parameter
    @IsActive BIT = 1                   -- Optional parameter with default value 1
AS
BEGIN
    -- Dynamic WHERE clause based on provided parameters
    SELECT 
        CustomerID,
        FirstName,
        LastName,
        Email,
        Phone,
        CreatedDate,
        IsActive
    FROM Customers
    WHERE 
        (@FirstName IS NULL OR FirstName LIKE '%' + @FirstName + '%')  -- Search by first name if provided
        AND (@LastName IS NULL OR LastName LIKE '%' + @LastName + '%') -- Search by last name if provided
        AND IsActive = @IsActive;  -- Filter by active status
END
GO

-- Test with different parameter combinations
EXEC SearchCustomers;                                    -- All active customers (using defaults)
EXEC SearchCustomers @FirstName = 'John';               -- Active customers with 'John' in first name
EXEC SearchCustomers @LastName = 'Smith', @IsActive = 1; -- Active customers with 'Smith' in last name
EXEC SearchCustomers @IsActive = 0;                     -- Inactive customers
GO

-- ===============================================
-- SECTION 5: OUTPUT PARAMETERS
-- ===============================================

-- Output parameters let you return values back to the calling code
-- Use OUTPUT keyword after the parameter

CREATE PROCEDURE CreateCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,         -- Optional parameter
    @NewCustomerID INT OUTPUT           -- OUTPUT parameter to return the new ID
AS
BEGIN
    -- Start transaction for data consistency
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Check if email already exists
        IF EXISTS (SELECT 1 FROM Customers WHERE Email = @Email)
        BEGIN
            RAISERROR('Email address already exists', 16, 1);
            RETURN;
        END
        
        -- Insert new customer
        INSERT INTO Customers (FirstName, LastName, Email, Phone)
        VALUES (@FirstName, @LastName, @Email, @Phone);
        
        -- Get the ID of the newly inserted customer
        SET @NewCustomerID = SCOPE_IDENTITY();  -- SCOPE_IDENTITY() returns last inserted ID in current scope
        
        -- Commit transaction if everything succeeded
        COMMIT TRANSACTION;
        
        PRINT 'Customer created successfully with ID: ' + CAST(@NewCustomerID AS NVARCHAR(10));
        
    END TRY
    BEGIN CATCH
        -- If any error occurs, rollback the transaction
        ROLLBACK TRANSACTION;
        
        -- Re-throw the error
        THROW;
    END CATCH
END
GO

-- Test the procedure with output parameter
DECLARE @NewID INT;  -- Variable to receive the output parameter

EXEC CreateCustomer 
    @FirstName = 'Mike',
    @LastName = 'Wilson',
    @Email = 'mike.wilson@email.com',
    @Phone = '555-0105',
    @NewCustomerID = @NewID OUTPUT;  -- OUTPUT keyword required when calling

-- Display the returned ID
PRINT 'New customer ID is: ' + CAST(@NewID AS NVARCHAR(10));
GO

-- ===============================================
-- SECTION 6: RETURN VALUES AND ERROR HANDLING
-- ===============================================

-- Stored procedures can return integer values using RETURN statement
-- By convention: 0 = success, negative numbers = different error types

CREATE PROCEDURE UpdateCustomerEmail
    @CustomerID INT,
    @NewEmail NVARCHAR(100)
AS
BEGIN
    -- Error codes we'll use
    DECLARE @SUCCESS INT = 0;
    DECLARE @CUSTOMER_NOT_FOUND INT = -1;
    DECLARE @EMAIL_ALREADY_EXISTS INT = -2;
    DECLARE @INVALID_INPUT INT = -3;
    
    -- Validate inputs
    IF @CustomerID IS NULL OR @CustomerID <= 0 OR @NewEmail IS NULL OR @NewEmail = ''
    BEGIN
        RETURN @INVALID_INPUT;
    END
    
    -- Check if customer exists
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerID)
    BEGIN
        RETURN @CUSTOMER_NOT_FOUND;
    END
    
    -- Check if email is already used by another customer
    IF EXISTS (SELECT 1 FROM Customers WHERE Email = @NewEmail AND CustomerID != @CustomerID)
    BEGIN
        RETURN @EMAIL_ALREADY_EXISTS;
    END
    
    -- Update the email
    UPDATE Customers 
    SET Email = @NewEmail 
    WHERE CustomerID = @CustomerID;
    
    RETURN @SUCCESS;  -- Return success code
END
GO

-- Test the procedure and check return value
DECLARE @ReturnValue INT;

EXEC @ReturnValue = UpdateCustomerEmail 
    @CustomerID = 1, 
    @NewEmail = 'john.doe.updated@email.com';

-- Check what happened based on return value
IF @ReturnValue = 0
    PRINT 'Email updated successfully';
ELSE IF @ReturnValue = -1
    PRINT 'Customer not found';
ELSE IF @ReturnValue = -2
    PRINT 'Email already exists for another customer';
ELSE IF @ReturnValue = -3
    PRINT 'Invalid input parameters';
GO

-- ===============================================
-- SECTION 7: ADVANCED FEATURES - LOOPS AND CURSORS
-- ===============================================

-- Sometimes you need to process data row by row
-- CURSORS allow you to iterate through result sets

CREATE PROCEDURE ProcessPendingOrders
AS
BEGIN
    -- Declare variables for cursor data
    DECLARE @OrderID INT;
    DECLARE @CustomerID INT;
    DECLARE @TotalAmount DECIMAL(10,2);
    DECLARE @ProcessedCount INT = 0;
    
    -- Declare cursor - this defines what data we'll iterate through
    DECLARE order_cursor CURSOR FOR
        SELECT OrderID, CustomerID, TotalAmount
        FROM Orders
        WHERE Status = 'Pending';
    
    -- Open cursor to start using it
    OPEN order_cursor;
    
    -- Fetch first row
    FETCH NEXT FROM order_cursor INTO @OrderID, @CustomerID, @TotalAmount;
    
    -- Loop through all rows (@@FETCH_STATUS = 0 means successful fetch)
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Process each order (example: apply discount for large orders)
        IF @TotalAmount > 100
        BEGIN
            UPDATE Orders 
            SET TotalAmount = @TotalAmount * 0.95,  -- 5% discount
                Status = 'Processed'
            WHERE OrderID = @OrderID;
            
            PRINT 'Applied discount to Order ID: ' + CAST(@OrderID AS NVARCHAR(10));
        END
        ELSE
        BEGIN
            -- Just mark as processed
            UPDATE Orders 
            SET Status = 'Processed'
            WHERE OrderID = @OrderID;
        END
        
        SET @ProcessedCount = @ProcessedCount + 1;
        
        -- Fetch next row
        FETCH NEXT FROM order_cursor INTO @OrderID, @CustomerID, @TotalAmount;
    END
    
    -- Clean up cursor
    CLOSE order_cursor;
    DEALLOCATE order_cursor;
    
    PRINT 'Processed ' + CAST(@ProcessedCount AS NVARCHAR(10)) + ' orders';
END
GO

-- Test the cursor procedure
EXEC ProcessPendingOrders;
GO

-- ===============================================
-- SECTION 8: DYNAMIC SQL IN STORED PROCEDURES
-- ===============================================

-- Sometimes you need to build SQL statements dynamically
-- Use this carefully to avoid SQL injection attacks!

CREATE PROCEDURE GetCustomerDataDynamic
    @TableName NVARCHAR(50),            -- Which table to query
    @OrderByColumn NVARCHAR(50) = 'CustomerID',  -- Which column to sort by
    @SortDirection NVARCHAR(4) = 'ASC'  -- Sort direction
AS
BEGIN
    -- Validate table name to prevent SQL injection
    IF @TableName NOT IN ('Customers', 'Orders')
    BEGIN
        RAISERROR('Invalid table name', 16, 1);
        RETURN;
    END
    
    -- Validate sort direction
    IF @SortDirection NOT IN ('ASC', 'DESC')
    BEGIN
        SET @SortDirection = 'ASC';
    END
    
    -- Build dynamic SQL string
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'SELECT * FROM ' + QUOTENAME(@TableName) +  -- QUOTENAME adds brackets to prevent injection
               ' ORDER BY ' + QUOTENAME(@OrderByColumn) + ' ' + @SortDirection;
    
    -- Show what SQL will be executed (for learning purposes)
    PRINT 'Executing: ' + @SQL;
    
    -- Execute dynamic SQL
    EXEC sp_executesql @SQL;  -- sp_executesql is safer than EXEC for dynamic SQL
END
GO

-- Test dynamic SQL procedure
EXEC GetCustomerDataDynamic @TableName = 'Customers', @OrderByColumn = 'LastName', @SortDirection = 'DESC';
GO

-- ===============================================
-- SECTION 9: STORED PROCEDURES WITH TABLE-VALUED PARAMETERS
-- ===============================================

-- Table-valued parameters let you pass entire tables as parameters
-- First, create a user-defined table type

CREATE TYPE CustomerTableType AS TABLE (
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    Phone NVARCHAR(20)
);
GO

-- Now create a procedure that accepts this table type
CREATE PROCEDURE BulkInsertCustomers
    @CustomerData CustomerTableType READONLY  -- READONLY is required for table parameters
AS
BEGIN
    DECLARE @InsertedCount INT = 0;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Insert all customers from the table parameter
        INSERT INTO Customers (FirstName, LastName, Email, Phone)
        SELECT FirstName, LastName, Email, Phone
        FROM @CustomerData
        WHERE Email NOT IN (SELECT Email FROM Customers WHERE Email IS NOT NULL);  -- Skip duplicates
        
        SET @InsertedCount = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        PRINT 'Successfully inserted ' + CAST(@InsertedCount AS NVARCHAR(10)) + ' customers';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Test table-valued parameter
DECLARE @NewCustomers CustomerTableType;

-- Insert data into the table variable
INSERT INTO @NewCustomers VALUES
('Sarah', 'Connor', 'sarah.connor@email.com', '555-0201'),
('Kyle', 'Reese', 'kyle.reese@email.com', '555-0202'),
('John', 'Connor', 'john.connor@email.com', '555-0203');

-- Call the procedure with table parameter
EXEC BulkInsertCustomers @CustomerData = @NewCustomers;
GO

-- ===============================================
-- SECTION 10: BEST PRACTICES AND OPTIMIZATION
-- ===============================================

-- Here's an example incorporating many best practices
CREATE PROCEDURE GetCustomerOrdersSummary
    @CustomerID INT = NULL,
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    -- SET NOCOUNT ON prevents sending row count messages to client (improves performance)
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @StartDate > @EndDate
    BEGIN
        RAISERROR('Start date cannot be greater than end date', 16, 1);
        RETURN;
    END
    
    -- Use meaningful aliases and proper formatting
    SELECT 
        c.CustomerID,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        c.Email,
        COUNT(o.OrderID) AS TotalOrders,
        ISNULL(SUM(o.TotalAmount), 0) AS TotalSpent,  -- ISNULL handles NULL values
        ISNULL(AVG(o.TotalAmount), 0) AS AverageOrderValue,
        MAX(o.OrderDate) AS LastOrderDate,
        c.CreatedDate AS CustomerSince
    FROM Customers c
        LEFT JOIN Orders o ON c.CustomerID = o.CustomerID  -- LEFT JOIN includes customers with no orders
            AND (@StartDate IS NULL OR o.OrderDate >= @StartDate)
            AND (@EndDate IS NULL OR o.OrderDate <= @EndDate)
    WHERE 
        (@CustomerID IS NULL OR c.CustomerID = @CustomerID)
        AND (c.IsActive = 1 OR @IncludeInactive = 1)
    GROUP BY 
        c.CustomerID, 
        c.FirstName, 
        c.LastName, 
        c.Email, 
        c.CreatedDate
    ORDER BY 
        TotalSpent DESC,  -- Order by highest spending customers first
        CustomerName;
    
    -- Return summary information
    SELECT 
        COUNT(*) AS CustomersReturned,
        SUM(CASE WHEN o.OrderID IS NOT NULL THEN 1 ELSE 0 END) AS CustomersWithOrders
    FROM Customers c
        LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    WHERE 
        (@CustomerID IS NULL OR c.CustomerID = @CustomerID)
        AND (c.IsActive = 1 OR @IncludeInactive = 1);
END
GO

-- Test the optimized procedure
EXEC GetCustomerOrdersSummary;
EXEC GetCustomerOrdersSummary @CustomerID = 1;
EXEC GetCustomerOrdersSummary @StartDate = '2024-01-01', @EndDate = '2024-12-31';
GO

-- ===============================================
-- SECTION 11: VIEWING AND MANAGING STORED PROCEDURES
-- ===============================================

-- View all stored procedures in current database
SELECT 
    name AS ProcedureName,
    create_date,
    modify_date,
    type_desc
FROM sys.procedures
ORDER BY name;

-- View the definition of a stored procedure
-- Method 1: Using sp_helptext
EXEC sp_helptext 'GetAllCustomers';

-- Method 2: Using OBJECT_DEFINITION function
SELECT OBJECT_DEFINITION(OBJECT_ID('GetAllCustomers'));

-- Method 3: Query system views
SELECT 
    p.name AS ProcedureName,
    m.definition AS ProcedureCode
FROM sys.procedures p
    INNER JOIN sys.sql_modules m ON p.object_id = m.object_id
WHERE p.name = 'GetAllCustomers';

-- ===============================================
-- SECTION 12: CLEANUP AND MANAGEMENT
-- ===============================================

-- Drop a stored procedure
-- DROP PROCEDURE GetAllCustomers;

-- Alter (modify) an existing stored procedure
-- ALTER PROCEDURE GetAllCustomers
-- AS
-- BEGIN
--     -- Modified code here
-- END

-- Grant execute permissions to a user/role
-- GRANT EXECUTE ON GetAllCustomers TO [username];

-- Check procedure dependencies
SELECT 
    p.name AS ProcedureName,
    d.referenced_entity_name AS DependsOn
FROM sys.procedures p
    INNER JOIN sys.sql_expression_dependencies d ON p.object_id = d.referencing_id
WHERE p.name = 'GetCustomerOrdersSummary';

-- ===============================================
-- TUTORIAL COMPLETE!
-- ===============================================

/* 
SUMMARY OF KEY CONCEPTS LEARNED:

1. Basic stored procedure creation and execution
2. Input parameters with validation
3. Default parameter values
4. Output parameters
5. Return values for error handling
6. Transaction management
7. Cursors for row-by-row processing
8. Dynamic SQL construction
9. Table-valued parameters
10. Best practices for performance and security
11. System views for procedure management

NEXT STEPS:
- Practice creating procedures for your own use cases
- Learn about stored procedure security
- Explore advanced topics like CLR procedures
- Study execution plans for performance tuning
- Learn about stored procedure caching and recompilation
*/
