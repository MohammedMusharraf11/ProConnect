-- Verification Script: Check if triggers, procedures, and tables exist
-- Run this to verify your database setup

USE professional_network;

-- ============================================
-- CHECK TABLES
-- ============================================
SELECT 'Checking Tables...' as status;

SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CREATE_TIME
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'professional_network'
ORDER BY TABLE_NAME;

-- ============================================
-- CHECK TRIGGERS
-- ============================================
SELECT 'Checking Triggers...' as status;

SELECT 
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'professional_network'
ORDER BY TRIGGER_NAME;

-- Expected Triggers:
-- 1. after_post_like_insert
-- 2. after_post_like_delete
-- 3. after_comment_insert
-- 4. after_comment_delete
-- 5. after_comment_like_insert
-- 6. after_comment_like_delete
-- 7. after_post_insert
-- 8. after_connection_accepted

-- ============================================
-- CHECK STORED PROCEDURES
-- ============================================
SELECT 'Checking Stored Procedures...' as status;

SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CREATED,
    LAST_ALTERED
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'professional_network'
AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

-- Expected Procedures:
-- 1. GetUserFeed
-- 2. GetUserActivity
-- 3. GetMutualConnectionsCount
-- 4. GetConnectionSuggestions

-- ============================================
-- CHECK FUNCTIONS
-- ============================================
SELECT 'Checking Functions...' as status;

SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CREATED,
    LAST_ALTERED
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'professional_network'
AND ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;

-- Expected Functions:
-- 1. GetConnectionCount
-- 2. GetPostCount
-- 3. GetMutualConnectionCount
-- 4. IsConnected
-- 5. GetUserFullName
-- 6. CalculateProfileCompleteness

-- ============================================
-- CHECK USER_ACTIVITY TABLE
-- ============================================
SELECT 'Checking USER_ACTIVITY table...' as status;

SELECT COUNT(*) as activity_count FROM USER_ACTIVITY;

-- ============================================
-- CHECK PHONE FIELD
-- ============================================
SELECT 'Checking PHONE field in USERS table...' as status;

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'professional_network'
AND TABLE_NAME = 'USERS'
AND COLUMN_NAME = 'PHONE';

-- ============================================
-- SUMMARY
-- ============================================
SELECT 'Database Verification Complete!' as status;

-- Count triggers
SELECT COUNT(*) as trigger_count, 
       'Expected: 8' as expected
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'professional_network';

-- Count procedures
SELECT COUNT(*) as procedure_count,
       'Expected: 4' as expected
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'professional_network'
AND ROUTINE_TYPE = 'PROCEDURE';

-- Count functions
SELECT COUNT(*) as function_count,
       'Expected: 6' as expected
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'professional_network'
AND ROUTINE_TYPE = 'FUNCTION';

-- Check if PHONE field exists
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'PHONE field exists ✓'
        ELSE 'PHONE field missing ✗'
    END as phone_status
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'professional_network'
AND TABLE_NAME = 'USERS'
AND COLUMN_NAME = 'PHONE';

-- Check if USER_ACTIVITY table exists
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'USER_ACTIVITY table exists ✓'
        ELSE 'USER_ACTIVITY table missing ✗'
    END as activity_table_status
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'professional_network'
AND TABLE_NAME = 'USER_ACTIVITY';
