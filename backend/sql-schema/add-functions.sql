-- Add SQL Functions to Database
-- Functions are reusable SQL code that return a single value

USE professional_network;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS GetConnectionCount;
DROP FUNCTION IF EXISTS GetPostCount;
DROP FUNCTION IF EXISTS GetMutualConnectionCount;
DROP FUNCTION IF EXISTS IsConnected;
DROP FUNCTION IF EXISTS GetUserFullName;
DROP FUNCTION IF EXISTS CalculateProfileCompleteness;

DELIMITER //

-- ============================================
-- FUNCTION 1: Get Connection Count for a User
-- ============================================
CREATE FUNCTION GetConnectionCount(p_user_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE connection_count INT;
    
    SELECT COUNT(*) INTO connection_count
    FROM CONNECTIONS
    WHERE (REQUEST_ID = p_user_id OR RECEIVER_ID = p_user_id)
    AND STATUS = 'accepted';
    
    RETURN connection_count;
END//

-- ============================================
-- FUNCTION 2: Get Post Count for a User
-- ============================================
CREATE FUNCTION GetPostCount(p_user_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE post_count INT;
    
    SELECT COUNT(*) INTO post_count
    FROM POSTS
    WHERE USER_ID = p_user_id;
    
    RETURN post_count;
END//

-- ============================================
-- FUNCTION 3: Get Mutual Connection Count Between Two Users
-- ============================================
CREATE FUNCTION GetMutualConnectionCount(p_user_id1 INT, p_user_id2 INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE mutual_count INT;
    
    SELECT COUNT(*) INTO mutual_count
    FROM (
        SELECT CASE 
            WHEN REQUEST_ID = p_user_id1 THEN RECEIVER_ID
            WHEN RECEIVER_ID = p_user_id1 THEN REQUEST_ID
        END as connection_id
        FROM CONNECTIONS
        WHERE (REQUEST_ID = p_user_id1 OR RECEIVER_ID = p_user_id1)
        AND STATUS = 'accepted'
    ) as user1_connections
    INNER JOIN (
        SELECT CASE 
            WHEN REQUEST_ID = p_user_id2 THEN RECEIVER_ID
            WHEN RECEIVER_ID = p_user_id2 THEN REQUEST_ID
        END as connection_id
        FROM CONNECTIONS
        WHERE (REQUEST_ID = p_user_id2 OR RECEIVER_ID = p_user_id2)
        AND STATUS = 'accepted'
    ) as user2_connections
    ON user1_connections.connection_id = user2_connections.connection_id;
    
    RETURN mutual_count;
END//

-- ============================================
-- FUNCTION 4: Check if Two Users are Connected
-- ============================================
CREATE FUNCTION IsConnected(p_user_id1 INT, p_user_id2 INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE connection_status VARCHAR(20);
    
    SELECT STATUS INTO connection_status
    FROM CONNECTIONS
    WHERE (
        (REQUEST_ID = p_user_id1 AND RECEIVER_ID = p_user_id2) OR
        (REQUEST_ID = p_user_id2 AND RECEIVER_ID = p_user_id1)
    )
    LIMIT 1;
    
    IF connection_status IS NULL THEN
        RETURN 'not_connected';
    ELSE
        RETURN connection_status;
    END IF;
END//

-- ============================================
-- FUNCTION 5: Get User's Full Name
-- ============================================
CREATE FUNCTION GetUserFullName(p_user_id INT)
RETURNS VARCHAR(201)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE full_name VARCHAR(201);
    
    SELECT CONCAT(F_NAME, ' ', L_NAME) INTO full_name
    FROM USERS
    WHERE USER_ID = p_user_id;
    
    RETURN COALESCE(full_name, 'Unknown User');
END//

-- ============================================
-- FUNCTION 6: Calculate Profile Completeness Percentage
-- ============================================
CREATE FUNCTION CalculateProfileCompleteness(p_user_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE completeness INT DEFAULT 0;
    DECLARE has_bio INT DEFAULT 0;
    DECLARE has_headline INT DEFAULT 0;
    DECLARE has_phone INT DEFAULT 0;
    DECLARE has_location INT DEFAULT 0;
    DECLARE has_industry INT DEFAULT 0;
    DECLARE has_profile_pic INT DEFAULT 0;
    DECLARE has_experience INT DEFAULT 0;
    DECLARE has_education INT DEFAULT 0;
    DECLARE has_skills INT DEFAULT 0;
    DECLARE has_projects INT DEFAULT 0;
    
    -- Check basic profile fields (10 points each)
    SELECT 
        CASE WHEN BIO IS NOT NULL AND BIO != '' THEN 10 ELSE 0 END,
        CASE WHEN HEADLINE IS NOT NULL AND HEADLINE != '' THEN 10 ELSE 0 END,
        CASE WHEN PHONE IS NOT NULL AND PHONE != '' THEN 10 ELSE 0 END,
        CASE WHEN CITY IS NOT NULL AND CITY != '' THEN 10 ELSE 0 END,
        CASE WHEN INDUSTRY IS NOT NULL AND INDUSTRY != '' THEN 10 ELSE 0 END,
        CASE WHEN PROFILE_PIC_URL IS NOT NULL AND PROFILE_PIC_URL != '' THEN 10 ELSE 0 END
    INTO has_bio, has_headline, has_phone, has_location, has_industry, has_profile_pic
    FROM USERS
    WHERE USER_ID = p_user_id;
    
    -- Check if user has experience (10 points)
    SELECT CASE WHEN COUNT(*) > 0 THEN 10 ELSE 0 END INTO has_experience
    FROM EXPERIENCE WHERE USER_ID = p_user_id;
    
    -- Check if user has education (10 points)
    SELECT CASE WHEN COUNT(*) > 0 THEN 10 ELSE 0 END INTO has_education
    FROM EDUCATION WHERE USER_ID = p_user_id;
    
    -- Check if user has skills (10 points)
    SELECT CASE WHEN COUNT(*) > 0 THEN 10 ELSE 0 END INTO has_skills
    FROM SKILLS WHERE USER_ID = p_user_id;
    
    -- Check if user has projects (10 points)
    SELECT CASE WHEN COUNT(*) > 0 THEN 10 ELSE 0 END INTO has_projects
    FROM PROJECTS WHERE USER_ID = p_user_id;
    
    -- Calculate total (max 100%)
    SET completeness = has_bio + has_headline + has_phone + has_location + 
                      has_industry + has_profile_pic + has_experience + 
                      has_education + has_skills + has_projects;
    
    RETURN completeness;
END//

DELIMITER ;

-- ============================================
-- TEST THE FUNCTIONS
-- ============================================

-- Test GetConnectionCount
SELECT 'Testing GetConnectionCount...' as test;
SELECT USER_ID, GetConnectionCount(USER_ID) as connection_count 
FROM USERS LIMIT 5;

-- Test GetPostCount
SELECT 'Testing GetPostCount...' as test;
SELECT USER_ID, GetPostCount(USER_ID) as post_count 
FROM USERS LIMIT 5;

-- Test GetUserFullName
SELECT 'Testing GetUserFullName...' as test;
SELECT USER_ID, GetUserFullName(USER_ID) as full_name 
FROM USERS LIMIT 5;

-- Test CalculateProfileCompleteness
SELECT 'Testing CalculateProfileCompleteness...' as test;
SELECT USER_ID, CalculateProfileCompleteness(USER_ID) as completeness_percentage 
FROM USERS LIMIT 5;

-- Test IsConnected (if you have at least 2 users)
SELECT 'Testing IsConnected...' as test;
SELECT IsConnected(1, 2) as connection_status;

-- Test GetMutualConnectionCount (if you have at least 2 users)
SELECT 'Testing GetMutualConnectionCount...' as test;
SELECT GetMutualConnectionCount(1, 2) as mutual_connections;

SELECT 'All functions created and tested successfully!' as status;
