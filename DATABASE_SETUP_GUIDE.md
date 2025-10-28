# Database Setup & Verification Guide

## What You Need

Your database should have:
- ✅ **8 Triggers** - Auto-update counts and log activities
- ✅ **4 Stored Procedures** - Complex queries for feed, activity, suggestions
- ✅ **USER_ACTIVITY Table** - Track all user actions
- ✅ **PHONE Field** - In USERS table

## Step 1: Verify Current Setup

Run this command to check what's installed:

```bash
mysql -u root -pviper professional_network < backend/sql-schema/verify-database.sql
```

Or in MySQL Workbench/CLI:
```sql
source backend/sql-schema/verify-database.sql
```

### What to Look For:

**Triggers (Should have 8):**
1. `after_post_like_insert` - Increment post likes
2. `after_post_like_delete` - Decrement post likes
3. `after_comment_insert` - Increment comment count
4. `after_comment_delete` - Decrement comment count
5. `after_comment_like_insert` - Increment comment likes
6. `after_comment_like_delete` - Decrement comment likes
7. `after_post_insert` - Log post creation
8. `after_connection_accepted` - Log new connections

**Stored Procedures (Should have 4):**
1. `GetUserFeed` - Get posts from connections
2. `GetUserActivity` - Get user activity history
3. `GetMutualConnectionsCount` - Count mutual connections
4. `GetConnectionSuggestions` - Suggest 2nd degree connections

## Step 2: Install Missing Components

### If Nothing is Installed (Fresh Database):

```bash
mysql -u root -pviper professional_network < backend/sql-schema/schema.sql
```

### If Database Exists but Missing Triggers/Procedures:

```bash
mysql -u root -pviper professional_network < backend/sql-schema/migration-add-triggers.sql
```

### If Only PHONE Field is Missing:

```bash
mysql -u root -pviper professional_network < backend/sql-schema/add-phone-field.sql
```

## Step 3: Verify Installation

Run the verification script again:

```bash
mysql -u root -pviper professional_network < backend/sql-schema/verify-database.sql
```

### Expected Output:

```
Trigger Count: 8 (Expected: 8) ✓
Procedure Count: 4 (Expected: 4) ✓
PHONE field exists ✓
USER_ACTIVITY table exists ✓
```

## Step 4: Test Functionality

### Test Triggers:

```sql
-- Test post like trigger
INSERT INTO POST_LIKES (POST_ID, USER_ID) VALUES (1, 1);
SELECT LIKES_COUNT FROM POSTS WHERE POST_ID = 1;
-- Should increment by 1

-- Test comment trigger
INSERT INTO COMMENTS (POST_ID, USER_ID, CONTENT) VALUES (1, 1, 'Test');
SELECT COMMENTS_COUNT FROM POSTS WHERE POST_ID = 1;
-- Should increment by 1

-- Check activity log
SELECT * FROM USER_ACTIVITY ORDER BY CREATED_AT DESC LIMIT 5;
-- Should show recent activities
```

### Test Stored Procedures:

```sql
-- Test GetUserActivity
CALL GetUserActivity(1, 10);
-- Should return user's recent activities

-- Test GetMutualConnectionsCount
CALL GetMutualConnectionsCount(1, 2);
-- Should return count of mutual connections

-- Test GetConnectionSuggestions
CALL GetConnectionSuggestions(1, 5);
-- Should return suggested connections
```

## Common Issues & Fixes

### Issue 1: "Trigger already exists"
**Solution:** Drop and recreate
```sql
DROP TRIGGER IF EXISTS after_post_like_insert;
-- Then run migration again
```

### Issue 2: "Procedure already exists"
**Solution:** Drop and recreate
```sql
DROP PROCEDURE IF EXISTS GetUserFeed;
-- Then run migration again
```

### Issue 3: Counts are wrong
**Solution:** Run count fix queries
```sql
-- Fix post likes count
UPDATE POSTS p SET LIKES_COUNT = (
    SELECT COUNT(*) FROM POST_LIKES pl WHERE pl.POST_ID = p.POST_ID
);

-- Fix comments count
UPDATE POSTS p SET COMMENTS_COUNT = (
    SELECT COUNT(*) FROM COMMENTS c WHERE c.POST_ID = p.POST_ID
);

-- Fix comment likes count
UPDATE COMMENTS c SET LIKES_COUNT = (
    SELECT COUNT(*) FROM COMMENT_LIKES cl WHERE cl.COMMENT_ID = c.COMMENT_ID
);
```

### Issue 4: USER_ACTIVITY table missing
**Solution:** Create it manually
```sql
CREATE TABLE USER_ACTIVITY (
    ACTIVITY_ID INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID INT NOT NULL,
    ACTIVITY_TYPE ENUM('post', 'comment', 'like_post', 'like_comment', 'connection') NOT NULL,
    REFERENCE_ID INT NOT NULL,
    ACTIVITY_TEXT TEXT,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE,
    INDEX idx_user (USER_ID),
    INDEX idx_type (ACTIVITY_TYPE),
    INDEX idx_created (CREATED_AT)
);
```

## Quick Check Commands

### List all triggers:
```sql
SHOW TRIGGERS FROM professional_network;
```

### List all procedures:
```sql
SHOW PROCEDURE STATUS WHERE Db = 'professional_network';
```

### Check table structure:
```sql
DESCRIBE USERS;
DESCRIBE USER_ACTIVITY;
```

### View trigger definition:
```sql
SHOW CREATE TRIGGER after_post_like_insert;
```

### View procedure definition:
```sql
SHOW CREATE PROCEDURE GetUserActivity;
```

## Why These Are Important

### Triggers:
- **Auto-update counts** - No need to manually update LIKES_COUNT, COMMENTS_COUNT
- **Activity logging** - Automatically track user actions
- **Data consistency** - Counts always match actual data

### Stored Procedures:
- **Complex queries** - Encapsulate business logic
- **Performance** - Pre-compiled and optimized
- **Reusability** - Call from multiple places
- **Maintainability** - Update logic in one place

### USER_ACTIVITY Table:
- **Activity feed** - Show what users are doing
- **Analytics** - Track engagement
- **Notifications** - Know when to notify users
- **Audit trail** - Keep history of actions

## Files Reference

1. **schema.sql** - Complete database schema (for fresh install)
2. **migration-add-triggers.sql** - Add triggers/procedures to existing DB
3. **add-phone-field.sql** - Add PHONE field only
4. **verify-database.sql** - Check what's installed

## All Set? ✓

If verification shows:
- 8 triggers ✓
- 4 procedures ✓
- USER_ACTIVITY table ✓
- PHONE field ✓

Then you're good to go! Your database is fully configured.
