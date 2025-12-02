-- View transaction wait statistics
PRINT '=== Transaction Waits ===';
SELECT 
    wt.wait_type,
    wt.waiting_task_count,
    wt.wait_duration_ms,
    wt.max_wait_time_ms,
    wt.signal_wait_time_ms,
    wt.wait_time_ms * 1.0 / NULLIF(wt.waiting_task_count, 0) AS avg_wait_time_ms
FROM sys.dm_os_wait_stats wt
WHERE wt.wait_type LIKE '%TRAN%' 
    OR wt.wait_type IN ('LCK_M_%', 'PAGELATCH_%')
ORDER BY wt.wait_time_ms DESC;
GO

-- Check for blocking chains
PRINT '=== Blocking Chains ===';
WITH BlockingChain AS (
    SELECT 
        blocking.session_id AS blocking_session_id,
        blocked.session_id AS blocked_session_id,
        blocked.wait_time,
        blocked.wait_type,
        blocked.blocking_session_id,
        ROW_NUMBER() OVER (ORDER BY blocked.session_id) AS chain_level
    FROM sys.dm_exec_requests blocked
    JOIN sys.dm_exec_requests blocking ON blocked.blocking_session_id = blocking.session_id
    WHERE blocked.blocking_session_id > 0
)
SELECT 
    bc.blocking_session_id,
    bc.blocked_session_id,
    bc.wait_time / 1000.0 AS wait_seconds,
    bc.wait_type,
    es1.login_name AS blocking_user,
    es1.program_name AS blocking_program,
    es2.login_name AS blocked_user,
    es2.program_name AS blocked_program,
    t1.text AS blocking_query,
    t2.text AS blocked_query
FROM BlockingChain bc
JOIN sys.dm_exec_sessions es1 ON bc.blocking_session_id = es1.session_id
JOIN sys.dm_exec_sessions es2 ON bc.blocked_session_id = es2.session_id
CROSS APPLY sys.dm_exec_sql_text(
    (SELECT sql_handle FROM sys.dm_exec_requests WHERE session_id = bc.blocking_session_id)
) t1
CROSS APPLY sys.dm_exec_sql_text(
    (SELECT sql_handle FROM sys.dm_exec_requests WHERE session_id = bc.blocked_session_id)
) t2
ORDER BY bc.chain_level;
GO

-- Section 12: Summary and Next Steps
--------------------------------------------------------------------

/*
KEY TCL CONCEPTS COVERED:
1. Transaction Basics:
   - BEGIN TRANSACTION / BEGIN TRAN
   - COMMIT TRANSACTION / COMMIT
   - ROLLBACK TRANSACTION / ROLLBACK
   - SAVE TRANSACTION / SAVE TRAN

2. Transaction Properties (ACID):
   - Atomicity: All or nothing
   - Consistency: Data integrity maintained
   - Isolation: Concurrent transactions don't interfere
   - Durability: Committed changes persist

3. Isolation Levels:
   - READ UNCOMMITTED (Dirty reads allowed)
   - READ COMMITTED (Default, prevents dirty reads)
   - REPEATABLE READ (Prevents non-repeatable reads)
   - SERIALIZABLE (Prevents phantoms, highest isolation)
   - SNAPSHOT (Row versioning)
   - READ COMMITTED SNAPSHOT (Optimistic locking)

4. Error Handling Patterns:
   - TRY...CATCH blocks
   - XACT_STATE() function
   - Nested transactions with savepoints
   - Retry logic for deadlocks

5. Advanced Topics:
   - Distributed transactions (BEGIN DISTRIBUTED TRANSACTION)
   - Two-phase commit protocol
   - Batch processing with transactions
   - Transaction logging and monitoring

BEST PRACTICES:
1. Keep transactions as short as possible
2. Use appropriate isolation levels for each scenario
3. Always implement error handling
4. Use savepoints for complex operations
5. Monitor for blocking and deadlocks
6. Design for minimal locking contention
7. Use SET XACT_ABORT ON for automatic rollback on errors

COMMON PITFALLS TO AVOID:
1. Long-running transactions (cause blocking)
2. Missing error handling (orphaned transactions)
3. Incorrect isolation levels (performance vs consistency trade-off)
4. Not checking XACT_STATE() in CATCH blocks
5. Deadlock scenarios due to inconsistent object access order
6. Forgetting to COMMIT or ROLLBACK (transaction leaks)

TRANSACTION ISOLATION LEVELS COMPARISON:
| Level             | Dirty Reads | Non-repeatable | Phantoms | Concurrency |
|-------------------|-------------|----------------|----------|-------------|
| READ UNCOMMITTED  | Yes         | Yes            | Yes      | Highest     |
| READ COMMITTED    | No          | Yes            | Yes      | High        |
| REPEATABLE READ   | No          | No             | Yes      | Medium      |
| SERIALIZABLE      | No          | No             | No       | Low         |
| SNAPSHOT          | No          | No             | No       | High*       |

*Uses row versioning, not locking

COMMON TRANSACTION ERRORS:
1. Error 1205: Deadlock victim
2. Error 266: Transaction count mismatch (@@TRANCOUNT)
3. Error 3902: COMMIT requested with no BEGIN TRAN
4. Error 3903: ROLLBACK requested with no BEGIN TRAN

NEXT STEPS TO EXPLORE:
1. Transactional replication
2. Always On Availability Groups and transactions
3. In-Memory OLTP and native compiled procedures
4. Transactional consistency in distributed systems
5. Transaction log backup and recovery scenarios
6. Lock escalation and optimization
7. Temporal tables with system-versioning

INTERVIEW QUESTIONS TO MASTER:
1. Explain ACID properties with examples
2. Difference between COMMIT and ROLLBACK?
3. What are dirty reads, non-repeatable reads, and phantom reads?
4. How do you handle deadlocks?
5. When to use SAVE TRANSACTION?
6. What is XACT_ABORT and when to use it?
7. How do distributed transactions work?

OFFICIAL DOCUMENTATION:
- Transactions: https://docs.microsoft.com/sql/t-sql/language-elements/transactions-transact-sql
- Isolation Levels: https://docs.microsoft.com/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide
- Deadlocks: https://docs.microsoft.com/sql/relational-databases/sql-server-deadlocks-guide
- Error Handling: https://docs.microsoft.com/sql/t-sql/language-elements/try-catch-transact-sql

PRODUCTION READY PATTERNS:
1. Use explicit transactions for data modifications
2. Implement comprehensive error handling
3. Use appropriate timeouts
4. Monitor transaction duration and blocking
5. Implement retry logic for transient errors
6. Use snapshot isolation for reporting queries
7. Design batch processes with checkpointing
*/

-- Cleanup script (optional - comment out to preserve data)
/*
-- Clean up deadlock monitoring
DROP TABLE DeadlockEvents;
DROP TABLE TransactionLog;
DROP TABLE Transactions;
DROP TABLE BankAccounts;
DROP TABLE RemoteBankAccounts;
DROP TABLE Inventory;
DROP TABLE BatchProcessLog;

-- Drop procedures
DROP PROCEDURE IF EXISTS usp_TransferFunds;
DROP PROCEDURE IF EXISTS usp_SafeUpdateWithRetry;

-- Reset database
USE master;
ALTER DATABASE TCLTutorialDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE TCLTutorialDB;
*/
GO

-- Final summary
PRINT '========================================';
PRINT 'TCL TUTORIAL COMPLETED SUCCESSFULLY';
PRINT '========================================';
PRINT 'Key concepts covered:';
PRINT '1. Basic transactions (BEGIN, COMMIT, ROLLBACK)';
PRINT '2. Error handling with TRY...CATCH';
PRINT '3. Isolation levels and concurrency control';
PRINT '4. Nested transactions and savepoints';
PRINT '5. Distributed transactions';
PRINT '6. Batch processing patterns';
PRINT '7. Deadlock prevention and handling';
PRINT '8. Transaction monitoring and DMVs';
PRINT '========================================';
PRINT 'Remember: Transactions ensure data integrity';
PRINT 'but must be designed carefully for performance.';
PRINT '========================================';
GO

-- Quick reference: Common transaction patterns

-- Pattern 1: Simple transaction with error handling
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Your DML operations here
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    THROW; -- Or handle error appropriately
END CATCH
GO

-- Pattern 2: Transaction with savepoints
BEGIN TRANSACTION;
    SAVE TRANSACTION SavePoint1;
    
    BEGIN TRY
        -- Operations that might fail
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION SavePoint1;
        -- Continue with other operations
    END CATCH
    
COMMIT TRANSACTION;
GO

-- Pattern 3: Nested transaction pattern
BEGIN TRANSACTION OuterTran;
    
    BEGIN TRY
        BEGIN TRANSACTION InnerTran;
        
        -- Operations
        
        COMMIT TRANSACTION InnerTran;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() = 1  -- Active transaction
            ROLLBACK TRANSACTION InnerTran;
        
        -- Handle error
    END CATCH
    
    -- More operations
    
COMMIT TRANSACTION OuterTran;
GO

-- Pattern 4: Batch processing with transactions
DECLARE @BatchSize INT = 1000;
DECLARE @Processed INT = 0;

WHILE @Processed < @TotalRecords
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Process batch
        
        COMMIT TRANSACTION;
        SET @Processed = @Processed + @BatchSize;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Log error and continue with next batch
    END CATCH
END
GO

PRINT 'Transaction patterns demonstrated successfully';
GO
