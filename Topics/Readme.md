Just in case you do not like what you see and want to create your own?
Here is a master prompt that can help
# SQL TUTORIAL GENERATOR - MASTER PROMPT

Use this prompt with any LLM to generate comprehensive SQL tutorials similar to the Stored Procedures document.

---

## THE PROMPT

```
You are an expert SQL educator creating a comprehensive, production-ready tutorial.

TOPIC TO COVER: [TOPIC NAME - e.g., DDL, DML, TRIGGERS, CTEs, WINDOW FUNCTIONS, etc.]

TUTORIAL REQUIREMENTS:

1. **Structure**: Create a complete SQL script with 12 sections following this exact format:
   - Section 1: Basic Setup and Understanding (create tutorial database + sample tables)
   - Section 2: Fundamental Concepts (simplest examples with detailed comments)
   - Section 3-4: Core Functionality (building complexity incrementally)
   - Section 5-6: Intermediate Techniques (multiple parameters/conditions/variations)
   - Section 7-8: Advanced Features (complex scenarios, performance considerations)
   - Section 9: Real-World Application (combining multiple concepts)
   - Section 10: Best Practices and Optimization
   - Section 11: Viewing/Managing [TOPIC] (system views, metadata queries)
   - Section 12: Summary with key takeaways and next steps

2. **Code Style**:
   - Every SQL statement must be executable in sequence
   - Use GO batch separators appropriately
   - Include extensive inline comments explaining:
     * What the code does
     * Why it's written this way
     * What each parameter/clause means
     * Common pitfalls to avoid
   - Comment density: ~40% of lines should be comments
   - Use consistent formatting and indentation

3. **Teaching Approach**:
   - Start with "Hello World" equivalent examples
   - Build complexity incrementally (don't jump from basic to advanced)
   - Show multiple ways to accomplish the same task when relevant
   - Include validation, error handling, and edge cases
   - Each example should be immediately testable with included data

4. **Practical Examples**:
   - Use realistic business scenarios (Customers, Orders, Products, etc.)
   - Include sample data that makes sense for testing
   - Show both correct usage and common mistakes
   - Demonstrate performance implications where relevant

5. **Critical Elements**:
   - Transaction management (BEGIN TRAN, COMMIT, ROLLBACK)
   - Error handling (TRY...CATCH blocks)
   - Input validation
   - Performance tips (indexes, execution plans, etc.)
   - Security considerations
   - System catalog queries to inspect objects

6. **Code Comments Must Include**:
   - Explanation of syntax: -- Syntax: [COMMAND] [parameters]
   - Parameter definitions: -- @param: description
   - Return value explanations
   - Common use cases: -- Use this when...
   - Performance notes: -- Note: This approach is faster because...
   - Warnings: -- WARNING: This can cause...

7. **End-of-Section Testing**:
   - Each section must end with executable test queries
   - Show expected output in comments
   - Include both success and failure scenarios

8. **Final Summary**:
   - Bullet-point list of all concepts covered
   - "Next Steps" section with related topics to learn
   - Common interview questions about the topic
   - Links to official documentation (as comments)

DELIVERABLE FORMAT:
- Single .sql file with all sections
- File should be 500-800 lines of code + comments
- Executable from top to bottom without errors
- Self-contained (creates own database and cleanup)

TONE:
- Professional but conversational
- Explain like teaching a junior developer
- Anticipate confusion and address it proactively
- Include "gotchas" and "pro tips" in comments

Now generate the complete tutorial for: [TOPIC]
```

---

## USAGE INSTRUCTIONS

**Step 1**: Copy the prompt above

**Step 2**: Replace `[TOPIC]` with your desired SQL topic:
- DDL (Data Definition Language)
- DML (Data Manipulation Language)
- DQL (Data Query Language)
- DCL (Data Control Language)
- TCL (Transaction Control Language)
- TRIGGERS
- SUBQUERIES
- CTEs (Common Table Expressions)
- WINDOW FUNCTIONS
- INDEXES
- VIEWS
- FUNCTIONS (Scalar & Table-Valued)
- CONSTRAINTS
- JOINS
- AGGREGATIONS
- PIVOTS & UNPIVOTS
- RECURSIVE QUERIES
- TEMP TABLES & TABLE VARIABLES
- ERROR HANDLING
- DYNAMIC SQL
- PERFORMANCE TUNING
- EXECUTION PLANS
- QUERY OPTIMIZATION
- PARTITIONING
- CURSORS
- TRANSACTIONS & LOCKING
- XML/JSON DATA HANDLING
- FULL-TEXT SEARCH
- etc.

**Step 3**: Paste into your preferred LLM (Claude, ChatGPT, etc.)

**Step 4**: Review and test the generated tutorial

**Step 5**: Save as `[TOPIC]_Complete_Tutorial.sql`

---

## EXAMPLE USAGE

```
[Paste the master prompt and replace [TOPIC] with:]

WINDOW FUNCTIONS
```

The LLM will generate:
- ROW_NUMBER, RANK, DENSE_RANK examples
- LAG/LEAD with detailed explanations
- Aggregate window functions
- PARTITION BY and ORDER BY clauses
- Frame specifications (ROWS vs RANGE)
- Real-world analytics scenarios
- Performance optimization tips
- System catalog queries
- Complete working examples

---

## QUICK TOPIC REFERENCE

**Foundational Topics** (start here):
- DDL → DML → DQL → TCL → DCL

**Intermediate Topics**:
- JOINS → SUBQUERIES → CTEs → VIEWS → INDEXES

**Advanced Topics**:
- WINDOW FUNCTIONS → TRIGGERS → STORED PROCEDURES → FUNCTIONS → DYNAMIC SQL

**Optimization Topics**:
- EXECUTION PLANS → QUERY OPTIMIZATION → INDEXES → PARTITIONING

---

## CUSTOMIZATION OPTIONS

Add these modifiers to the prompt for specific needs:

**For Specific SQL Dialect**:
```
Generate this tutorial specifically for [T-SQL / PostgreSQL / MySQL / Oracle]
Highlight dialect-specific features and syntax differences.
```

**For Performance Focus**:
```
Include detailed performance analysis for each approach.
Add EXPLAIN/EXECUTION PLAN examples.
Compare alternatives with benchmark timings.
```

**For Interview Prep**:
```
Include common interview questions after each section.
Add complexity ratings (Junior/Mid/Senior level).
Provide "gotcha" questions and their answers.
```

**For Certification Prep**:
```
Align examples with [Microsoft SQL Server / Oracle / MySQL] certification objectives.
Include exam-style questions and scenarios.
```

---

## QUALITY CHECKLIST

After generating, verify:
- [ ] All code executes without errors
- [ ] Database cleanup at end (DROP DATABASE)
- [ ] Each section has test queries
- [ ] Comments explain "why" not just "what"
- [ ] Includes error handling examples
- [ ] Shows system catalog queries
- [ ] Has performance considerations
- [ ] Includes best practices section
- [ ] Summary with next steps
- [ ] Realistic business examples

---

## PRO TIPS

1. **Generate multiple topics in sequence** to build a complete learning path
2. **Combine topics** for advanced tutorials (e.g., "TRIGGERS + ERROR HANDLING")
3. **Request comparisons** (e.g., "CTEs vs SUBQUERIES vs TEMP TABLES")
4. **Ask for real-world scenarios** from your actual work
5. **Request dialect translations** if migrating databases

---

## EXAMPLE OUTPUT STRUCTURE

```sql
-- ===============================================
-- [TOPIC] COMPLETE TUTORIAL
-- ===============================================
-- Execute step by step and read all comments

-- SECTION 1: BASIC SETUP
USE master;
GO
CREATE DATABASE [Topic]Tutorial;
GO
-- ... [creates tables, sample data]

-- SECTION 2: FUNDAMENTAL CONCEPTS
-- Simplest possible example with extensive explanation
-- ... [code with 40%+ comments]

-- ... [Sections 3-11 building complexity]

-- SECTION 12: SUMMARY
/* 
KEY CONCEPTS LEARNED:
1. [Concept]
2. [Concept]
...

NEXT STEPS:
- [Related topic]
- [Advanced feature]
*/
```

---

## SAVE THIS PROMPT

Bookmark or save this master prompt. Whenever you need a tutorial, just:
1. Grab the prompt
2. Insert your topic
3. Generate
4. Learn efficiently

**Time saved per topic**: ~10-15 hours of manual documentation
**Quality**: Production-ready, tested, comprehensive
**Format**: Consistent across all SQL concepts
