/*
================================================================================
COMPREHENSIVE SQL DCL TUTORIAL
Author: SQL Expert
Date: 2024
Description: Complete guide to Data Control Language (DCL) with production-ready examples
================================================================================
*/

-- Section 0: Setup and Initialization
--------------------------------------------------------------------
-- Create a dedicated database for this tutorial
-- DCL = Data Control Language (GRANT, DENY, REVOKE)
-- Focuses on security and permissions management
--------------------------------------------------------------------

USE master;
GO

-- Check if tutorial database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DCLTutorialDB')
BEGIN
    -- Check for active connections and kill them
    DECLARE @kill VARCHAR(8000) = '';
    SELECT @kill = @kill + 'KILL ' + CONVERT(VARCHAR(5), session_id) + ';'
    FROM sys.dm_exec_sessions
    WHERE database_id = DB_ID('DCLTutorialDB');
    
    EXEC(@kill);
    
    ALTER DATABASE DCLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DCLTutorialDB;
END
GO

-- Create a fresh database for our tutorial
CREATE DATABASE DCLTutorialDB;
GO

USE DCLTutorialDB;
GO

-- Create a master key for encryption demonstration
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'DCLTutorial@2024!';
GO

-- Create certificate for column encryption
CREATE CERTIFICATE DCLTutorialCert
WITH SUBJECT = 'DCL Tutorial Certificate';
GO

-- Section 1: Basic Setup and Understanding
--------------------------------------------------------------------
-- Create sample tables with realistic business schema
-- We'll use a banking scenario for security-focused examples
--------------------------------------------------------------------

-- Create schemas for logical separation
CREATE SCHEMA Banking AUTHORIZATION dbo;
GO

CREATE SCHEMA HR AUTHORIZATION dbo;
GO

CREATE SCHEMA Audit AUTHORIZATION dbo;
GO

CREATE SCHEMA Reporting AUTHORIZATION dbo;
GO

-- Create main tables with sensitive data
CREATE TABLE Banking.Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerSSN VARCHAR(11) NOT NULL,  -- Sensitive: Social Security Number
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    DateOfBirth DATE NOT NULL,
    CreditScore INT,
    AnnualIncome DECIMAL(12,2),
    RiskRating CHAR(1) DEFAULT 'A',  -- A=Low, B=Medium, C=High risk
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(128) DEFAULT SYSTEM_USER,
    -- Constraints
    CONSTRAINT CHK_Customers_SSN CHECK (CustomerSSN LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    CONSTRAINT CHK_Customers_CreditScore CHECK (CreditScore BETWEEN 300 AND 850),
    CONSTRAINT CHK_Customers_RiskRating CHECK (RiskRating IN ('A', 'B', 'C'))
);
GO

-- Create encrypted column for sensitive data
CREATE TABLE Banking.Accounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountNumber VARCHAR(20) NOT NULL UNIQUE,
    AccountType VARCHAR(20) DEFAULT 'Checking',
    -- Encrypted balance column
    Balance DECIMAL(15,2) NOT NULL,
    EncryptedBalance VARBINARY(256),  -- Will be encrypted
    InterestRate DECIMAL(5,3) DEFAULT 0.01,
    Status VARCHAR(20) DEFAULT 'Active',
    OpenedDate DATE DEFAULT GETDATE(),
    ClosedDate DATE NULL,
    -- Foreign key
    CONSTRAINT FK_Accounts_Customers FOREIGN KEY (CustomerID)
        REFERENCES Banking.Customers(CustomerID),
    -- Check constraints
    CONSTRAINT CHK_Accounts_Balance CHECK (Balance >= 0),
    CONSTRAINT CHK_Accounts_Type CHECK (AccountType IN ('Checking', 'Savings', 'Investment')),
    CONSTRAINT CHK_Accounts_Dates CHECK (OpenedDate <= ISNULL(ClosedDate, '9999-12-31'))
);
GO

-- Setup encryption for balance column
CREATE SYMMETRIC KEY AccountBalanceKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE DCLTutorialCert;
GO

-- Create transaction table
CREATE TABLE Banking.Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    Description NVARCHAR(200),
    SourceAccountID INT NULL,
    DestinationAccountID INT NULL,
    TransactionStatus VARCHAR(20) DEFAULT 'Completed',
    -- Foreign keys
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountID)
        REFERENCES Banking.Accounts(AccountID),
    -- Check constraints
    CONSTRAINT CHK_Transactions_Type CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer', 'Interest')),
    CONSTRAINT CHK_Transactions_Amount CHECK (Amount > 0)
);
GO

-- Create HR tables
CREATE TABLE HR.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeSSN VARCHAR(11) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Department VARCHAR(50),
    Position VARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE DEFAULT GETDATE(),
    TerminationDate DATE NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT CHK_Employees_SSN CHECK (EmployeeSSN LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
);
GO

-- Create audit log table
CREATE TABLE Audit.SecurityLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EventTime DATETIME DEFAULT GETDATE(),
    EventType VARCHAR(50) NOT NULL,
    UserName NVARCHAR(128) DEFAULT SYSTEM_USER,
    ObjectName NVARCHAR(128),
    ActionDetails NVARCHAR(MAX),
    IPAddress VARCHAR(45),
    IsSuccessful BIT DEFAULT 1
);
GO

-- Insert sample data
INSERT INTO Banking.Customers (CustomerSSN, FirstName, LastName, Email, DateOfBirth, CreditScore, AnnualIncome, RiskRating)
VALUES 
    ('123-45-6789', 'John', 'Smith', 'john.smith@email.com', '1980-05-15', 750, 85000.00, 'A'),
    ('987-65-4321', 'Maria', 'Garcia', 'maria.g@email.com', '1990-08-22', 680, 65000.00, 'B'),
    ('456-78-9012', 'David', 'Chen', 'david.chen@email.com', '1975-12-10', 820, 120000.00, 'A');

INSERT INTO Banking.Accounts (CustomerID, AccountNumber, AccountType, Balance)
VALUES
    (1, 'CHECK001', 'Checking', 5000.00),
    (1, 'SAVE001', 'Savings', 15000.00),
    (2, 'CHECK002', 'Checking', 2500.00),
    (3, 'CHECK003', 'Checking', 10000.00);

-- Encrypt the balances
OPEN SYMMETRIC KEY AccountBalanceKey
DECRYPTION BY CERTIFICATE DCLTutorialCert;

UPDATE Banking.Accounts
SET EncryptedBalance = EncryptByKey(Key_GUID('AccountBalanceKey'), CONVERT(VARCHAR(50), Balance));

CLOSE SYMMETRIC KEY AccountBalanceKey;
GO

INSERT INTO Banking.Transactions (AccountID, TransactionType, Amount, Description)
VALUES
    (1, 'Deposit', 1000.00, 'Initial deposit'),
    (1, 'Withdrawal', 200.00, 'ATM withdrawal'),
    (2, 'Deposit', 5000.00, 'Payroll deposit');

INSERT INTO HR.Employees (EmployeeSSN, FirstName, LastName, Email, Department, Position, Salary)
VALUES
    ('111-22-3333', 'Robert', 'Johnson', 'robert.j@bank.com', 'Teller', 'Senior Teller', 45000.00),
    ('222-33-4444', 'Sarah', 'Williams', 'sarah.w@bank.com', 'Management', 'Branch Manager', 85000.00),
    ('333-44-5555', 'Michael', 'Brown', 'michael.b@bank.com', 'IT', 'Database Admin', 95000.00);

SELECT 'Sample data inserted successfully' AS Status;
GO

-- Section 2: Fundamental Concepts - Creating Security Principals
--------------------------------------------------------------------
-- Security principals: Logins (server-level) and Users (database-level)
--------------------------------------------------------------------

-- Create server-level logins (commented out as we can't create real logins without sysadmin)
/*
-- Syntax: CREATE LOGIN [login_name] WITH PASSWORD = 'password'
CREATE LOGIN BankManager WITH PASSWORD = 'BankMgr@2024!';
CREATE LOGIN BankTeller WITH PASSWORD = 'Teller@2024!';
CREATE LOGIN BankAuditor WITH PASSWORD = 'Auditor@2024!';
CREATE LOGIN ReportUser WITH PASSWORD = 'Reports@2024!';
*/

-- Instead, create database users without logins (for tutorial purposes)
-- Syntax: CREATE USER [user_name] [FOR|FROM] LOGIN [login_name]
CREATE USER BankManager WITHOUT LOGIN;
CREATE USER BankTeller WITHOUT LOGIN;
CREATE USER BankAuditor WITHOUT LOGIN;
CREATE USER ReportUser WITHOUT LOGIN;
CREATE USER ITAdmin WITHOUT LOGIN;
CREATE USER AppUser WITHOUT LOGIN;
GO

-- View created users
SELECT 
    name AS UserName,
    principal_id,
    type_desc AS UserType,
    default_schema_name AS DefaultSchema,
    create_date
FROM sys.database_principals
WHERE type IN ('S', 'U')  -- SQL user and Windows user
ORDER BY principal_id DESC;
GO

-- Section 3: Core Functionality - Creating Roles
--------------------------------------------------------------------
-- Roles group users for easier permission management
-- Database roles vs Application roles
--------------------------------------------------------------------

-- Create custom database roles
-- Syntax: CREATE ROLE [role_name]
CREATE ROLE BankManagerRole;
CREATE ROLE BankTellerRole;
CREATE ROLE BankAuditorRole;
CREATE ROLE ReportViewerRole;
CREATE ROLE DatabaseMaintainerRole;
CREATE ROLE SensitiveDataReaderRole;
GO

-- Add users to roles
-- Syntax: ALTER ROLE [role_name] ADD MEMBER [user_name]
ALTER ROLE BankManagerRole ADD MEMBER BankManager;
ALTER ROLE BankTellerRole ADD MEMBER BankTeller;
ALTER ROLE BankAuditorRole ADD MEMBER BankAuditor;
ALTER ROLE ReportViewerRole ADD MEMBER ReportUser;
ALTER ROLE DatabaseMaintainerRole ADD MEMBER ITAdmin;
ALTER ROLE db_datareader ADD MEMBER AppUser;  -- Built-in role
GO

-- Create application role (for application connections)
-- Syntax: CREATE APPLICATION ROLE [role_name] WITH PASSWORD = 'password'
CREATE APPLICATION ROLE BankAppRole
WITH PASSWORD = 'AppRole@2024!',
DEFAULT_SCHEMA = Banking;
GO

-- View role memberships
SELECT 
    r.name AS RoleName,
    m.name AS MemberName,
    m.type_desc AS MemberType
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name LIKE '%Role%' OR r.name LIKE 'db_%'
ORDER BY r.name, m.name;
GO

-- Section 4: Core Functionality - GRANT Permissions
--------------------------------------------------------------------
-- GRANT gives permissions to users/roles
-- Object-level vs Schema-level permissions
--------------------------------------------------------------------

-- Grant schema-level permissions to roles
-- Syntax: GRANT [permission] ON SCHEMA::[schema_name] TO [principal]
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Banking TO BankManagerRole;
GRANT SELECT, UPDATE ON SCHEMA::Banking TO BankTellerRole;
GRANT SELECT ON SCHEMA::Banking TO BankAuditorRole;
GRANT SELECT ON SCHEMA::Reporting TO ReportViewerRole;
GRANT CONTROL ON SCHEMA::dbo TO DatabaseMaintainerRole;
GO

-- Grant specific object permissions (more granular)
-- Syntax: GRANT [permission] ON [object_type]::[object_name] TO [principal]
GRANT SELECT ON OBJECT::Banking.Customers TO BankTellerRole;
GRANT SELECT ON OBJECT::Banking.Accounts TO BankTellerRole;
GRANT INSERT, UPDATE ON OBJECT::Banking.Transactions TO BankTellerRole;

-- Grant with GRANT OPTION (allows recipient to grant to others)
GRANT SELECT ON OBJECT::HR.Employees TO BankManagerRole
WITH GRANT OPTION;

-- Grant execute permission on all procedures in schema
GRANT EXECUTE ON SCHEMA::Banking TO BankManagerRole;
GO

-- Grant column-level permissions (very granular)
-- Syntax: GRANT [permission] ([column_list]) ON [object] TO [principal]
GRANT SELECT (CustomerID, FirstName, LastName, Email, Phone) 
ON Banking.Customers 
TO ReportViewerRole;

-- Deny access to sensitive columns
GRANT SELECT ON Banking.Customers TO BankTellerRole;
DENY SELECT (CustomerSSN, AnnualIncome, CreditScore, RiskRating) 
ON Banking.Customers 
TO BankTellerRole;
GO

-- Test permissions by switching users (simulated)
PRINT 'Testing Teller role permissions:';
EXECUTE AS USER = 'BankTeller';
SELECT 
    USER_NAME() AS CurrentUser,
    HAS_PERMS_BY_NAME('Banking.Customers', 'OBJECT', 'SELECT') AS HasSelectOnCustomers,
    HAS_PERMS_BY_NAME('Banking.Customers', 'OBJECT', 'INSERT') AS HasInsertOnCustomers,
    HAS_PERMS_BY_NAME('Banking.Customers.CustomerSSN', 'COLUMN', 'SELECT') AS HasSelectOnSSN;
REVERT;
GO

-- Section 5: Intermediate Techniques - DENY Permissions
--------------------------------------------------------------------
-- DENY explicitly denies permissions (overrides GRANT)
-- Useful for explicit security restrictions
--------------------------------------------------------------------

-- Create conflicting permissions to demonstrate DENY priority
-- User gets role permission (GRANT) but explicit DENY overrides it
CREATE USER TestUser WITHOUT LOGIN;
GO

ALTER ROLE BankTellerRole ADD MEMBER TestUser;
GO

-- Explicitly deny specific permissions to TestUser
DENY SELECT ON OBJECT::Banking.Customers TO TestUser;
DENY INSERT ON SCHEMA::Banking TO TestUser;
GO

-- Test DENY priority
PRINT 'Testing DENY priority:';
EXECUTE AS USER = 'TestUser';
SELECT 
    USER_NAME() AS CurrentUser,
    HAS_PERMS_BY_NAME('Banking.Customers', 'OBJECT', 'SELECT') AS CanSelectCustomers,
    HAS_PERMS_BY_NAME('Banking.Accounts', 'OBJECT', 'SELECT') AS CanSelectAccounts;
REVERT;
GO

-- Remove test user
ALTER ROLE BankTellerRole DROP MEMBER TestUser;
DROP USER TestUser;
GO

-- Section 6: Intermediate Techniques - REVOKE Permissions
--------------------------------------------------------------------
-- REVOKE removes previously granted or denied permissions
-- Returns to inherited state or no permission
--------------------------------------------------------------------

-- Demonstrate REVOKE by removing specific permissions
-- First, grant some permissions
GRANT SELECT, INSERT, UPDATE ON OBJECT::Banking.Transactions TO BankTellerRole;
GRANT DELETE ON OBJECT::Banking.Transactions TO BankManagerRole;
GO

-- Check current permissions
PRINT 'Permissions before REVOKE:';
EXECUTE AS USER = 'BankTeller';
SELECT 
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'SELECT') AS CanSelect,
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'INSERT') AS CanInsert,
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'UPDATE') AS CanUpdate,
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'DELETE') AS CanDelete;
REVERT;
GO

-- Now REVOKE specific permissions
REVOKE INSERT, UPDATE ON OBJECT::Banking.Transactions FROM BankTellerRole;
REVOKE DELETE ON OBJECT::Banking.Transactions FROM BankManagerRole;
GO

-- Verify permissions after REVOKE
PRINT 'Permissions after REVOKE:';
EXECUTE AS USER = 'BankTeller';
SELECT 
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'SELECT') AS CanSelect,
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'INSERT') AS CanInsert,
    HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'UPDATE') AS CanUpdate;
REVERT;
GO

-- Section 7: Advanced Features - Dynamic Data Masking
--------------------------------------------------------------------
-- DDM masks sensitive data at query time
-- Different masking functions for different data types
--------------------------------------------------------------------

-- Add dynamic data masking to sensitive columns
-- Syntax: ALTER TABLE [table] ALTER COLUMN [column] ADD MASKED WITH (FUNCTION = 'mask_function()')

-- Email masking: Shows first letter + domain
ALTER TABLE Banking.Customers
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
GO

-- Partial masking: Shows first N characters, masks the rest
ALTER TABLE Banking.Customers
ALTER COLUMN CustomerSSN ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XX-",4)');
GO

-- Random masking for numeric data
ALTER TABLE Banking.Customers
ALTER COLUMN AnnualIncome ADD MASKED WITH (FUNCTION = 'random(30000, 80000)');
GO

-- Default masking (full mask)
ALTER TABLE Banking.Customers
ALTER COLUMN CreditScore ADD MASKED WITH (FUNCTION = 'default()');
GO

-- Custom string masking
ALTER TABLE HR.Employees
ALTER COLUMN EmployeeSSN ADD MASKED WITH (FUNCTION = 'partial(0,"***-**-",4)');
GO

-- Test masking with a low-privileged user
CREATE USER MaskedUser WITHOUT LOGIN;
GRANT SELECT ON Banking.Customers TO MaskedUser;
GRANT SELECT ON HR.Employees TO MaskedUser;
GO

PRINT 'Testing Dynamic Data Masking:';
EXECUTE AS USER = 'MaskedUser';
SELECT TOP 3 
    CustomerID,
    FirstName,
    LastName,
    Email,           -- Masked: aXXX@XXXX.com
    CustomerSSN,     -- Masked: XXX-XX-6789
    AnnualIncome,    -- Masked: Random between 30000-80000
    CreditScore      -- Masked: XXXX
FROM Banking.Customers;

SELECT TOP 3 
    EmployeeID,
    FirstName,
    LastName,
    EmployeeSSN      -- Masked: ***-**-3333
FROM HR.Employees;
REVERT;
GO

-- Grant UNMASK permission to see actual data
GRANT UNMASK ON Banking.Customers TO BankManagerRole;
GRANT UNMASK ON HR.Employees TO BankManagerRole;
GO

-- Test UNMASK permission
PRINT 'Testing UNMASK permission:';
EXECUTE AS USER = 'BankManager';
SELECT TOP 1 
    CustomerSSN,     -- Should show actual data
    AnnualIncome     -- Should show actual data
FROM Banking.Customers;
REVERT;
GO

-- Remove test user
DROP USER MaskedUser;
GO

-- Section 8: Advanced Features - Row-Level Security
--------------------------------------------------------------------
-- RLS filters rows based on user context
-- Implemented through security policies and predicates
--------------------------------------------------------------------

-- Create predicate function for RLS
-- Syntax: CREATE FUNCTION [schema].[function] (@column [type]) RETURNS TABLE WITH SCHEMABINDING
CREATE FUNCTION Banking.fn_CustomerAccessPredicate(@CustomerID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (
    SELECT 1 AS AccessResult
    WHERE USER_NAME() IN ('BankManager', 'BankAuditor', 'dbo')
       OR @CustomerID IN (
           -- Tellers can only access customers they have created accounts for
           SELECT DISTINCT a.CustomerID
           FROM Banking.Accounts a
           WHERE a.AccountNumber LIKE 'CHECK%'
              AND USER_NAME() = 'BankTeller'
       )
);
GO

-- Create security policy using the predicate
-- Syntax: CREATE SECURITY POLICY [policy_name] ADD FILTER PREDICATE [function] ON [table]
CREATE SECURITY POLICY Banking.CustomerSecurityPolicy
ADD FILTER PREDICATE Banking.fn_CustomerAccessPredicate(CustomerID)
ON Banking.Customers
WITH (STATE = ON);
GO

-- Test RLS with different users
PRINT 'Testing Row-Level Security:';

-- Test as Teller (should see limited customers)
EXECUTE AS USER = 'BankTeller';
SELECT 
    USER_NAME() AS CurrentUser,
    CustomerID,
    FirstName,
    LastName
FROM Banking.Customers;
REVERT;
GO

-- Test as Manager (should see all customers)
EXECUTE AS USER = 'BankManager';
SELECT 
    USER_NAME() AS CurrentUser,
    COUNT(*) AS CustomerCount
FROM Banking.Customers;
REVERT;
GO

-- Create block predicate for preventing certain operations
CREATE FUNCTION Banking.fn_CustomerBlockPredicate(@CustomerID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (
    SELECT 1 AS BlockResult
    WHERE USER_NAME() = 'BankTeller'
       AND @CustomerID IN (
           -- Tellers cannot modify high-risk customers
           SELECT CustomerID 
           FROM Banking.Customers 
           WHERE RiskRating = 'C'
       )
);
GO

-- Add block predicate to security policy
ALTER SECURITY POLICY Banking.CustomerSecurityPolicy
ADD BLOCK PREDICATE Banking.fn_CustomerBlockPredicate(CustomerID)
ON Banking.Customers AFTER UPDATE;
GO

-- Test block predicate
PRINT 'Testing Block Predicate:';
EXECUTE AS USER = 'BankTeller';
BEGIN TRY
    -- This should fail for high-risk customers
    UPDATE Banking.Customers
    SET CreditScore = 700
    WHERE CustomerID = 1 AND RiskRating = 'C';
    
    PRINT 'Update succeeded (customer not high risk)';
END TRY
BEGIN CATCH
    PRINT 'Blocked: ' + ERROR_MESSAGE();
END CATCH
REVERT;
GO

-- Section 9: Real-World Application - Complete Security Model
--------------------------------------------------------------------
-- Combine all DCL concepts in a production banking scenario
--------------------------------------------------------------------

-- Create comprehensive stored procedures with execute as
-- Syntax: CREATE PROCEDURE [proc] WITH EXECUTE AS [caller|self|owner|user]
CREATE PROCEDURE Banking.usp_ProcessTransaction
    @AccountID INT,
    @TransactionType VARCHAR(20),
    @Amount DECIMAL(15,2),
    @Description NVARCHAR(200) = NULL
WITH EXECUTE AS OWNER  -- Runs with procedure owner's permissions
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check permissions
        IF HAS_PERMS_BY_NAME('Banking.Transactions', 'OBJECT', 'INSERT') = 0
        BEGIN
            RAISERROR('Insufficient permissions to process transactions', 16, 1);
            RETURN;
        END
        
        -- Process transaction
        INSERT INTO Banking.Transactions (AccountID, TransactionType, Amount, Description)
        VALUES (@AccountID, @TransactionType, @Amount, @Description);
        
        -- Update account balance
        IF @TransactionType = 'Deposit'
            UPDATE Banking.Accounts SET Balance = Balance + @Amount WHERE AccountID = @AccountID;
        ELSE IF @TransactionType = 'Withdrawal'
            UPDATE Banking.Accounts SET Balance = Balance - @Amount WHERE AccountID = @AccountID;
        
        -- Log the action
        INSERT INTO Audit.SecurityLog (EventType, ObjectName, ActionDetails)
        VALUES ('TransactionProcessed', 'Banking.Transactions', 
                CONCAT('Account: ', @AccountID, ', Type: ', @TransactionType, ', Amount: ', @Amount));
        
        COMMIT TRANSACTION;
        PRINT 'Transaction processed successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Grant execute permission
GRANT EXECUTE ON Banking.usp_ProcessTransaction TO BankTellerRole;
GO

-- Test the procedure
PRINT 'Testing secured stored procedure:';
EXECUTE AS USER = 'BankTeller';
EXEC Banking.usp_ProcessTransaction 
    @AccountID = 1,
    @TransactionType = 'Deposit',
    @Amount = 500.00,
    @Description = 'Test deposit';
REVERT;
GO

-- Create view with column permissions and RLS
CREATE VIEW Banking.vw_CustomerFinancialSummary
WITH SCHEMABINDING
AS
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(a.AccountID) AS AccountCount,
    SUM(a.Balance) AS TotalBalance,
    AVG(CASE WHEN a.AccountType = 'Savings' THEN a.InterestRate END) AS AvgSavingsRate
FROM Banking.Customers c
JOIN Banking.Accounts a ON c.CustomerID = a.CustomerID
WHERE a.Status = 'Active'
GROUP BY c.CustomerID, c.FirstName, c.LastName;
GO

-- Grant column-specific permissions on view
GRANT SELECT ON Banking.vw_CustomerFinancialSummary TO ReportViewerRole;
DENY SELECT (TotalBalance) ON Banking.vw_CustomerFinancialSummary TO ReportViewerRole;
GO

-- Test view permissions
PRINT 'Testing view with column-level security:';
EXECUTE AS USER = 'ReportUser';
SELECT TOP 3 * FROM Banking.vw_CustomerFinancialSummary;
REVERT;
GO

-- Section 10: Best Practices and Security Auditing
--------------------------------------------------------------------
-- Security auditing, monitoring, and best practices
--------------------------------------------------------------------

-- Create audit specification (requires Enterprise/Developer edition)
-- Note: Server audit must be created at server level first
/*
-- At server level:
USE master;
GO
CREATE SERVER AUDIT BankSecurityAudit
TO FILE (FILEPATH = 'C:\Audits\', MAXSIZE = 1 GB)
WITH (ON_FAILURE = CONTINUE);
GO
ALTER SERVER AUDIT BankSecurityAudit WITH (STATE = ON);
GO

USE DCLTutorialDB;
CREATE DATABASE AUDIT SPECIFICATION BankDBAudit
FOR SERVER AUDIT BankSecurityAudit
ADD (SELECT, INSERT, UPDATE, DELETE ON Banking.Customers BY PUBLIC),
ADD (EXECUTE ON Banking.usp_ProcessTransaction BY PUBLIC),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP)
WITH (STATE = ON);
GO
*/

-- Create custom audit triggers
CREATE TRIGGER Audit_DB_PermissionChanges
ON DATABASE
FOR GRANT_DATABASE, DENY_DATABASE, REVOKE_DATABASE
AS
BEGIN
    DECLARE @EventData XML = EVENTDATA();
    
    INSERT INTO Audit.SecurityLog (EventType, ObjectName, ActionDetails)
    VALUES (
        'PermissionChange',
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(128)'),
        CONCAT(
            'User: ', @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(128)'),
            ', Command: ', @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
        )
    );
END;
GO

-- Create trigger to audit failed logins (simulated)
CREATE TRIGGER Audit_FailedAccess
ON Banking.Customers
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF HAS_PERMS_BY_NAME('Banking.Customers', 'OBJECT', 'SELECT') = 0
    BEGIN
        INSERT INTO Audit.SecurityLog (EventType, ObjectName, ActionDetails, IsSuccessful)
        VALUES ('UnauthorizedAccess', 'Banking.Customers', 
                'Attempted to modify customers without permissions', 0);
    END
END;
GO

-- Create security checklist view
CREATE VIEW Security.vw_PermissionReport
AS
SELECT
    USER_NAME(grantee_principal_id) AS Grantee,
    CASE class
        WHEN 0 THEN 'Database'
        WHEN 1 THEN 'Object'
        WHEN 3 THEN 'Schema'
        ELSE 'Other'
    END AS PermissionClass,
    CASE class
        WHEN 1 THEN OBJECT_NAME(major_id)
        WHEN 3 THEN SCHEMA_NAME(major_id)
        ELSE NULL
    END AS ObjectName,
    permission_name AS Permission,
    state_desc AS PermissionState
FROM sys.database_permissions
WHERE grantee_principal_id > 0
    AND grantee_principal_id < 16384  -- Exclude system roles
ORDER BY Grantee, class, ObjectName;
GO

-- Generate security report
SELECT * FROM Security.vw_PermissionReport;
GO

-- Section 11: Viewing and Managing Security Objects
--------------------------------------------------------------------
-- Query security metadata and manage permissions
--------------------------------------------------------------------

-- View all users and their roles
SELECT 
    p.name AS PrincipalName,
    p.type_desc AS PrincipalType,
    ISNULL(r.name, 'No role') AS RoleName,
    p.default_schema_name AS DefaultSchema,
    p.create_date
FROM sys.database_principals p
LEFT JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE p.type IN ('S', 'U', 'G')  -- SQL users, Windows users, Windows groups
    AND p.is_fixed_role = 0
ORDER BY p.type_desc, p.name;
GO

-- View effective permissions for a user
SELECT 
    USER_NAME(grantee_principal_id) AS UserName,
    permission_name AS Permission,
    state_desc AS State,
    OBJECT_NAME(major_id) AS ObjectName,
    CASE class
        WHEN 0 THEN 'Database'
        WHEN 1 THEN 'Object/Column'
        WHEN 3 THEN 'Schema'
        ELSE CAST(class AS VARCHAR(10))
    END AS Class
FROM sys.database_permissions
WHERE USER_NAME(grantee_principal_id) IN ('BankTeller', 'BankManager', 'ReportUser')
    AND state_desc IN ('GRANT', 'DENY')
ORDER BY UserName, class, ObjectName;
GO

-- View masked columns
SELECT
    t.name AS TableName,
    c.name AS ColumnName,
    c.is_masked AS IsMasked,
    c.masking_function AS MaskingFunction
FROM sys.masked_columns c
JOIN sys.tables t ON c.object_id = t.object_id
ORDER BY t.name, c.column_id;
GO

-- View RLS security policies
SELECT
    schema_name(schema_id) AS SchemaName,
    name AS PolicyName,
    is_enabled AS IsEnabled,
    create_date,
    modify_date
FROM sys.security_policies
ORDER BY SchemaName, name;
GO

-- View encryption keys
SELECT
    name AS KeyName,
    symmetric_key_id AS KeyID,
    key_length AS KeyLength,
    algorithm_desc AS Algorithm,
    create_date
FROM sys.symmetric_keys
WHERE name NOT LIKE '##%';
GO

-- Generate permission script for documentation
SELECT 
    'GRANT ' + permission_name + ' ON ' +
    CASE class
        WHEN 0 THEN 'DATABASE'
        WHEN 1 THEN OBJECT_NAME(major_id)
        WHEN 3 THEN 'SCHEMA::' + SCHEMA_NAME(major_id)
        ELSE ''
    END + ' TO ' + USER_NAME(grantee_principal_id) + ';' AS PermissionScript
FROM sys.database_permissions
WHERE state_desc = 'GRANT'
    AND grantee_principal_id > 0
    AND grantee_principal_id < 16384
ORDER BY grantee_principal_id, class;
GO

-- Section 12: Summary and Next Steps
--------------------------------------------------------------------
-- Key takeaways and resources for continued learning
--------------------------------------------------------------------

/*
KEY DCL COMMANDS COVERED:
1. GRANT: Gives permissions to users/roles
2. DENY: Explicitly denies permissions (overrides GRANT)
3. REVOKE: Removes previously granted/denied permissions

SECURITY PRINCIPALS:
1. Server-level: Logins
2. Database-level: Users, Roles, Application Roles
3. Built-in roles: db_owner, db_datareader, db_datawriter, etc.

PERMISSION HIERARCHY (most to least specific):
1. Column-level permissions
2. Object-level permissions
3. Schema-level permissions
4. Database-level permissions
5. Server-level permissions

PERMISSION STATES:
1. GRANT: Explicit permission
2. DENY: Explicit denial (overrides GRANT)
3. REVOKE: Removes GRANT or DENY (returns to inherited state)

ADVANCED SECURITY FEATURES:
1. Dynamic Data Masking (DDM): Masks sensitive data at query time
2. Row-Level Security (RLS): Filters rows based on user context
3. Always Encrypted: Encrypts data at rest and in transit
4. Audit Specifications: Tracks security-relevant events

PERMISSION TYPES:
1. CONTROL: Full control (includes all other permissions)
2. ALTER: Modify object structure
3. TAKE OWNERSHIP: Take ownership of object
4. IMPERSONATE: Execute as another user
5. VIEW DEFINITION: View object definition
6. SELECT, INSERT, UPDATE, DELETE, EXECUTE: Data manipulation

BEST PRACTICES:
1. Principle of Least Privilege: Grant minimum necessary permissions
2. Use roles for permission management, not individual users
3. Implement separation of duties
4. Regular security audits and reviews
5. Use schemas for logical organization and security boundaries
6. Implement defense in depth (multiple security layers)

COMMON PITFALLS TO AVOID:
1. Granting excessive permissions (especially CONTROL or db_owner)
2. Not using roles for permission management
3. Missing regular permission reviews
4. Hardcoding credentials in applications
5. Not implementing auditing
6. Ignoring column-level security for sensitive data

NEXT STEPS TO EXPLORE:
1. Always Encrypted with secure enclaves
2. Transparent Data Encryption (TDE)
3. SQL Server Audit with custom event filtering
4. Azure Active Directory authentication
5. Certificate-based authentication
6. Security compliance frameworks (GDPR, HIPAA, PCI DSS)

INTERVIEW QUESTIONS TO MASTER:
1. Difference between GRANT, DENY, and REVOKE?
2. How does permission inheritance work?
3. What is the principle of least privilege?
4. How do you implement row-level security?
5. What are the differences between roles and schemas?
6. How do you audit SQL Server security?

OFFICIAL DOCUMENTATION:
- Permissions: https://docs.microsoft.com/sql/relational-databases/security/permissions-database-engine
- Row-Level Security: https://docs.microsoft.com/sql/relational-databases/security/row-level-security
- Dynamic Data Masking: https://docs.microsoft.com/sql/relational-databases/security/dynamic-data-masking
- Always Encrypted: https://docs.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-database-engine
*/

-- Cleanup (optional - comment out to preserve tutorial database)
/*
USE master;
GO
ALTER DATABASE DCLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DCLTutorialDB;
GO
*/

-- Final summary
PRINT '========================================';
PRINT 'DCL TUTORIAL COMPLETED SUCCESSFULLY';
PRINT 'Concepts covered:';
PRINT '1. Users, Roles, and Permissions';
PRINT '2. GRANT, DENY, REVOKE commands';
PRINT '3. Dynamic Data Masking (DDM)';
PRINT '4. Row-Level Security (RLS)';
PRINT '5. Encryption and key management';
PRINT '6. Security auditing and monitoring';
PRINT '========================================';
GO
