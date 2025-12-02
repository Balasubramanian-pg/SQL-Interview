/*
================================================================================
COMPREHENSIVE SQL TRIGGERS TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to SQL Server Triggers with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- This ensures we don't interfere with existing databases
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
-- Using conditional drop to avoid errors on first run
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'TriggerTutorialDB')
BEGIN
    -- Disconnect existing connections before dropping
    ALTER DATABASE TriggerTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TriggerTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE TriggerTutorialDB;
GO

USE TriggerTutorialDB;
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create sample tables with realistic business schema
-- We'll use an e-commerce scenario: Customers, Products, Orders
--------------------------------------------------------------------

-- Create Customers table with basic information
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    TotalOrders INT DEFAULT 0,
    TotalSpent DECIMAL(10,2) DEFAULT 0.00,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastOrderDate DATETIME NULL
);
GO

-- Create Products table with inventory tracking
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10,
    IsActive BIT DEFAULT 1,
    LastRestockDate DATETIME NULL
);
GO

-- Create Orders table with foreign key relationships
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) DEFAULT 0.00,
    Status NVARCHAR(20) DEFAULT 'Pending',
    -- Foreign key constraints for data integrity
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID) ON DELETE CASCADE
);
GO

-- Create OrderDetails table for line items
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    LineTotal AS (Quantity * UnitPrice) PERSISTED,
    -- Foreign keys with appropriate actions
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) 
        REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) 
        REFERENCES Products(ProductID)
);
GO

-- Insert sample data to work with
INSERT INTO Customers (CustomerName, Email) VALUES
    ('John Smith', 'john.smith@email.com'),
    ('Maria Garcia', 'maria.garcia@email.com'),
    ('David Chen', 'david.chen@email.com');

INSERT INTO Products (ProductName, UnitPrice, StockQuantity, ReorderLevel) VALUES
    ('Laptop', 999.99, 25, 5),
    ('Mouse', 29.99, 100, 20),
    ('Keyboard', 79.99, 50, 10),
    ('Monitor', 299.99, 15, 3);

SELECT 'Tables created and populated with sample data' AS Status;
GO

-- Section 2: Fundamental Concepts - AFTER INSERT Trigger
--------------------------------------------------------------------
-- Triggers are special stored procedures that automatically execute
-- when certain events occur (INSERT, UPDATE, DELETE)
-- AFTER triggers fire AFTER the operation completes successfully
--------------------------------------------------------------------

-- Create our first trigger: Track customer's last order date
CREATE TRIGGER TR_Customers_UpdateLastOrder
ON Orders
AFTER INSERT
AS
BEGIN
    -- Syntax: CREATE TRIGGER [name] ON [table] AFTER [operation]
    -- This trigger fires after a new order is inserted
    
    SET NOCOUNT ON; -- Prevents "1 row affected" messages
    
    -- Update the customer's last order date
    UPDATE c
    SET LastOrderDate = i.OrderDate
    FROM Customers c
    INNER JOIN inserted i ON c.CustomerID = i.CustomerID;
    -- The "inserted" table is a special table available in triggers
    -- It contains the new row(s) that were just inserted
    
    PRINT 'Customer last order date updated successfully';
END;
GO

-- Test the AFTER INSERT trigger
INSERT INTO Orders (CustomerID, TotalAmount, Status) 
VALUES (1, 1299.98, 'Completed');

-- Verify the trigger worked
SELECT CustomerID, CustomerName, LastOrderDate 
FROM Customers 
WHERE CustomerID = 1;
-- Expected: LastOrderDate should show today's date/time
GO

-- Section 3: Core Functionality - AFTER UPDATE Trigger
--------------------------------------------------------------------
-- UPDATE triggers can track changes and maintain audit trails
-- They have access to both "inserted" (new values) and "deleted" (old values) tables
--------------------------------------------------------------------

-- Create audit table to track price changes
CREATE TABLE ProductPriceAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE(),
    ChangedBy NVARCHAR(100) DEFAULT SYSTEM_USER
);
GO

-- Create trigger to log price changes
CREATE TRIGGER TR_Products_LogPriceChange
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if UnitPrice was actually changed
    -- Using IF UPDATE(column) to optimize performance
    IF UPDATE(UnitPrice)
    BEGIN
        -- Insert audit records for all rows where price changed
        INSERT INTO ProductPriceAudit (ProductID, OldPrice, NewPrice)
        SELECT 
            i.ProductID,
            d.UnitPrice AS OldPrice,  -- From deleted table (old values)
            i.UnitPrice AS NewPrice   -- From inserted table (new values)
        FROM inserted i
        INNER JOIN deleted d ON i.ProductID = d.ProductID
        WHERE i.UnitPrice <> d.UnitPrice;  -- Only log actual changes
        
        PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' price change(s) logged';
    END
END;
GO

-- Test the UPDATE trigger
-- First check current state
SELECT ProductID, ProductName, UnitPrice FROM Products WHERE ProductID = 2;

-- Update the price (this should fire the trigger)
UPDATE Products 
SET UnitPrice = 34.99 
WHERE ProductID = 2;

-- Verify the audit trail
SELECT * FROM ProductPriceAudit;
-- Expected: One audit record showing price change from 29.99 to 34.99
GO

-- Section 4: Core Functionality - INSTEAD OF Trigger
--------------------------------------------------------------------
-- INSTEAD OF triggers fire INSTEAD OF the original operation
-- Useful for complex validations, computed columns, or overriding default behavior
--------------------------------------------------------------------

-- Create a view that joins customer and order information
CREATE VIEW CustomerOrderSummary
AS
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Email,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Email;
GO

-- Create INSTEAD OF INSERT trigger for the view
CREATE TRIGGER TR_CustomerOrderSummary_Insert
ON CustomerOrderSummary
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- INSTEAD OF triggers must explicitly perform the operation
    -- Here we'll insert into the base table
    INSERT INTO Customers (CustomerName, Email)
    SELECT CustomerName, Email
    FROM inserted;
    -- Note: We're only inserting into Customers, not Orders
    -- OrderCount and TotalSpent are computed columns
    
    PRINT 'Customer inserted via view trigger';
END;
GO

-- Test INSTEAD OF trigger by inserting through the view
INSERT INTO CustomerOrderSummary (CustomerName, Email)
VALUES ('Sarah Johnson', 'sarah.johnson@email.com');

-- Verify the insertion
SELECT * FROM Customers WHERE CustomerName = 'Sarah Johnson';
-- Expected: New customer record without orders
GO

-- Section 5: Intermediate Techniques - Handling Multiple Rows
--------------------------------------------------------------------
-- Triggers must handle multi-row operations correctly
-- Common mistake: Assuming single-row operations only
--------------------------------------------------------------------

-- Create a more robust order processing trigger
CREATE TRIGGER TR_Orders_ProcessOrder
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Handle multiple inserted rows using set-based operations
        -- Update customer statistics
        UPDATE c
        SET 
            TotalOrders = c.TotalOrders + 1,
            TotalSpent = c.TotalSpent + i.TotalAmount,
            LastOrderDate = i.OrderDate
        FROM Customers c
        INNER JOIN inserted i ON c.CustomerID = i.CustomerID;
        
        PRINT 'Customer statistics updated for ' + CAST(@@ROWCOUNT AS VARCHAR) + ' order(s)';
    END TRY
    BEGIN CATCH
        -- Log error but don't re-throw (orders still inserted)
        PRINT 'Error updating customer statistics: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Test multi-row insert
INSERT INTO Orders (CustomerID, TotalAmount, Status) VALUES
    (2, 199.99, 'Completed'),
    (3, 599.99, 'Completed'),
    (2, 89.99, 'Pending');

-- Verify updates
SELECT CustomerID, CustomerName, TotalOrders, TotalSpent 
FROM Customers 
ORDER BY CustomerID;
-- Expected: Customer 2 should have TotalOrders=2, TotalSpent=289.98
GO

-- Section 6: Intermediate Techniques - Nested and Recursive Triggers
--------------------------------------------------------------------
-- Triggers can fire other triggers (nested) or fire themselves (recursive)
-- Must be managed carefully to avoid infinite loops
--------------------------------------------------------------------

-- Enable/configure nested triggers (default is 1)
EXEC sp_configure 'nested triggers', 1;
RECONFIGURE;
GO

-- Create trigger that updates product stock when order details are inserted
CREATE TRIGGER TR_OrderDetails_UpdateStock
ON OrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update product stock levels
    UPDATE p
    SET StockQuantity = p.StockQuantity - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
    
    PRINT 'Stock levels updated for ' + CAST(@@ROWCOUNT AS VARCHAR) + ' product(s)';
END;
GO

-- Create trigger to check stock levels after update
CREATE TRIGGER TR_Products_CheckStockLevel
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if stock fell below reorder level
    IF EXISTS (
        SELECT 1 
        FROM inserted i 
        WHERE i.StockQuantity <= i.ReorderLevel
    )
    BEGIN
        PRINT 'ALERT: Some products need restocking!';
        -- In production, you might:
        -- 1. Send an email alert
        -- 2. Create a restock order
        -- 3. Log to monitoring system
    END
END;
GO

-- Test nested triggers
-- First check current stock
SELECT ProductID, ProductName, StockQuantity, ReorderLevel 
FROM Products 
WHERE ProductID = 1;

-- Insert order details (this will fire TR_OrderDetails_UpdateStock)
INSERT INTO Orders (CustomerID, TotalAmount) VALUES (1, 0);
DECLARE @OrderID INT = SCOPE_IDENTITY();

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
VALUES (@OrderID, 1, 22, 999.99);  -- Buy 22 laptops

-- Check stock after trigger chain
SELECT ProductID, ProductName, StockQuantity 
FROM Products 
WHERE ProductID = 1;
-- Expected: StockQuantity went from 25 to 3 (below reorder level of 5)
-- Should see "ALERT: Some products need restocking!" message
GO

-- Section 7: Advanced Features - DDL Triggers
--------------------------------------------------------------------
-- DDL triggers respond to CREATE, ALTER, DROP events
-- Useful for auditing schema changes and enforcing naming conventions
--------------------------------------------------------------------

-- Create table to track DDL events
CREATE TABLE SchemaChangeLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(255),
    ObjectType NVARCHAR(100),
    SQLCommand NVARCHAR(MAX),
    ChangedBy NVARCHAR(100),
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO

-- Create database-scoped DDL trigger
CREATE TRIGGER TR_AuditDDLEvents
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Capture event data using EVENTDATA() XML function
    DECLARE @EventData XML = EVENTDATA();
    
    INSERT INTO SchemaChangeLog (EventType, ObjectName, ObjectType, SQLCommand, ChangedBy)
    SELECT 
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)');
        
    PRINT 'DDL event logged successfully';
END;
GO

-- Test DDL trigger by creating a table
CREATE TABLE TestTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);

-- Check the audit log
SELECT * FROM SchemaChangeLog;
-- Expected: Record of CREATE_TABLE event for TestTable
GO

-- Section 8: Advanced Features - Trigger Management and Optimization
--------------------------------------------------------------------
-- Managing trigger execution order, disabling, and performance optimization
--------------------------------------------------------------------

-- Create another trigger on Orders to demonstrate execution order
CREATE TRIGGER TR_Orders_ValidateAmount
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate order amount
    IF EXISTS (SELECT 1 FROM inserted WHERE TotalAmount < 0)
    BEGIN
        RAISERROR('Order amount cannot be negative', 16, 1);
        ROLLBACK TRANSACTION;  -- Roll back the entire transaction
        RETURN;
    END
END;
GO

-- Set trigger execution order (first/last)
-- Note: sp_settriggerorder must be run separately for each trigger
EXEC sp_settriggerorder 
    @triggername = 'TR_Orders_ValidateAmount',
    @order = 'first',
    @stmttype = 'INSERT';
    
EXEC sp_settriggerorder 
    @triggername = 'TR_Orders_ProcessOrder', 
    @order = 'last', 
    @stmttype = 'INSERT';
GO

-- Test trigger order with negative amount (should be caught first)
BEGIN TRY
    INSERT INTO Orders (CustomerID, TotalAmount) VALUES (1, -100);
END TRY
BEGIN CATCH
    PRINT 'Error caught: ' + ERROR_MESSAGE();
END CATCH
GO

-- Disable a trigger temporarily
DISABLE TRIGGER TR_Orders_ValidateAmount ON Orders;

-- Now the insert should work (but violate business rule)
INSERT INTO Orders (CustomerID, TotalAmount) VALUES (1, -100);
SELECT * FROM Orders WHERE TotalAmount < 0;

-- Re-enable the trigger
ENABLE TRIGGER TR_Orders_ValidateAmount ON Orders;

-- Clean up invalid data
DELETE FROM Orders WHERE TotalAmount < 0;
GO

-- Section 9: Real-World Application - Complete Order Processing System
--------------------------------------------------------------------
-- Combine multiple triggers to create a robust order processing system
--------------------------------------------------------------------

-- Create comprehensive order processing trigger with transaction
CREATE TRIGGER TR_OrderDetails_CompleteProcessing
ON OrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorOccurred BIT = 0;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Update order total amount
        UPDATE o
        SET TotalAmount = (
            SELECT SUM(LineTotal) 
            FROM OrderDetails od 
            WHERE od.OrderID = o.OrderID
        )
        FROM Orders o
        WHERE o.OrderID IN (SELECT DISTINCT OrderID FROM inserted);
        
        -- 2. Update product stock
        UPDATE p
        SET StockQuantity = p.StockQuantity - i.Quantity
        FROM Products p
        INNER JOIN inserted i ON p.ProductID = i.ProductID;
        
        -- 3. Check for stockouts
        IF EXISTS (
            SELECT 1 
            FROM Products p
            INNER JOIN inserted i ON p.ProductID = i.ProductID
            WHERE p.StockQuantity < 0
        )
        BEGIN
            RAISERROR('Insufficient stock for one or more products', 16, 1);
            SET @ErrorOccurred = 1;
        END
        
        IF @ErrorOccurred = 0
        BEGIN
            COMMIT TRANSACTION;
            PRINT 'Order processed successfully';
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Re-throw error to client
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- Test complete order processing
BEGIN TRY
    -- Create new order
    INSERT INTO Orders (CustomerID) VALUES (1);
    DECLARE @NewOrderID INT = SCOPE_IDENTITY();
    
    -- Add items to order
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
        (@NewOrderID, 1, 1, 999.99),   -- Laptop
        (@NewOrderID, 2, 2, 34.99);    -- Mouse
    
    -- Verify results
    SELECT 'Order Total:' AS Description, TotalAmount FROM Orders WHERE OrderID = @NewOrderID;
    SELECT ProductID, ProductName, StockQuantity FROM Products WHERE ProductID IN (1, 2);
END TRY
BEGIN CATCH
    PRINT 'Processing error: ' + ERROR_MESSAGE();
END CATCH
GO

-- Section 10: Best Practices and Optimization
--------------------------------------------------------------------
-- Essential tips for production trigger development
--------------------------------------------------------------------

-- 1. Always use SET NOCOUNT ON
-- 2. Handle multi-row operations
-- 3. Use transactions appropriately
-- 4. Avoid cursors in triggers
-- 5. Keep triggers simple and fast

-- Create optimized trigger example
CREATE TRIGGER TR_Products_OptimizedUpdate
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only process rows that actually changed
    IF UPDATE(StockQuantity) OR UPDATE(ReorderLevel)
    BEGIN
        -- Use EXISTS instead of checking @@ROWCOUNT
        IF EXISTS (
            SELECT 1 
            FROM inserted i
            INNER JOIN deleted d ON i.ProductID = d.ProductID
            WHERE i.StockQuantity <= i.ReorderLevel
               AND d.StockQuantity > d.ReorderLevel
        )
        BEGIN
            -- Use minimal logging for large operations
            PRINT 'Products entered reorder state';
        END
    END
END;
GO

-- Performance consideration: Indexed views vs triggers
-- For complex aggregations, consider indexed views instead of triggers

-- Section 11: Viewing and Managing Triggers
--------------------------------------------------------------------
-- Query system catalog to inspect existing triggers
--------------------------------------------------------------------

-- View all triggers in the database
SELECT 
    OBJECT_NAME(t.object_id) AS TableName,
    t.name AS TriggerName,
    t.type_desc AS TriggerType,
    t.is_disabled AS IsDisabled,
    OBJECT_DEFINITION(t.object_id) AS TriggerDefinition
FROM sys.triggers t
WHERE t.parent_class = 1  -- Object triggers (not DDL)
ORDER BY TableName, TriggerName;
GO

-- View DDL triggers
SELECT 
    name AS TriggerName,
    type_desc AS TriggerType,
    is_disabled AS IsDisabled,
    parent_class_desc AS ParentType
FROM sys.triggers
WHERE parent_class = 0  -- Database triggers
   OR parent_class = 1; -- Server triggers
GO

-- View trigger dependencies
SELECT 
    OBJECT_NAME(referencing_id) AS TriggerName,
    referenced_entity_name AS ReferencesTable
FROM sys.sql_expression_dependencies
WHERE referencing_id IN (SELECT object_id FROM sys.triggers);
GO

-- View trigger execution order
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS TriggerName,
    isfirst AS IsFirst,
    islast AS IsLast,
    type_desc AS TriggerType
FROM sys.triggers
WHERE parent_id = OBJECT_ID('Orders')
ORDER BY isfirst DESC, islast DESC;
GO

-- Section 12: Summary and Next Steps
--------------------------------------------------------------------
-- Key takeaways and resources for continued learning
--------------------------------------------------------------------

/*
KEY CONCEPTS COVERED:
1. Trigger Types:
   - AFTER triggers (INSERT, UPDATE, DELETE)
   - INSTEAD OF triggers (for views and complex logic)
   - DDL triggers (CREATE, ALTER, DROP events)

2. Special Tables:
   - inserted: Contains new values (INSERT/UPDATE)
   - deleted: Contains old values (UPDATE/DELETE)

3. Best Practices:
   - Always use SET NOCOUNT ON
   - Handle multi-row operations
   - Avoid complex logic in triggers
   - Use transactions appropriately
   - Consider performance implications

4. Management:
   - Enable/disable triggers
   - Set execution order
   - Query system catalog views

COMMON PITFALLS TO AVOID:
1. Infinite loops from recursive triggers
2. Assuming single-row operations
3. Forgetting to handle NULL values
4. Not considering trigger order
5. Performing slow operations in triggers

NEXT STEPS TO EXPLORE:
1. Learn about CLR triggers for complex logic
2. Study trigger-based replication
3. Explore Change Data Capture (CDC) as an alternative
4. Practice with temporal tables for auditing
5. Understand trigger security context

INTERVIEW QUESTIONS TO MASTER:
1. What's the difference between AFTER and INSTEAD OF triggers?
2. How do you prevent infinite recursion in triggers?
3. When would you use a trigger vs. a stored procedure?
4. How do you handle multi-row operations in triggers?
5. What are the performance implications of triggers?

OFFICIAL DOCUMENTATION:
- Microsoft Docs: https://docs.microsoft.com/sql/t-sql/statements/create-trigger-transact-sql
- Trigger Best Practices: https://docs.microsoft.com/sql/relational-databases/triggers/implement-database-triggers

REMEMBER: Triggers are powerful but should be used judiciously.
Consider alternatives like computed columns, check constraints,
or application-level logic where appropriate.
*/

-- Cleanup (optional - comment out to preserve data)
/*
USE master;
GO
ALTER DATABASE TriggerTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE TriggerTutorialDB;
GO
*/

PRINT '========================================';
PRINT 'TUTORIAL COMPLETED SUCCESSFULLY';
PRINT 'Review each section and experiment with examples';
PRINT '========================================';
