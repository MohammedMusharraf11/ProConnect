# Quick Database Check

## Run This Command:

```bash
mysql -u root -pviper professional_network < backend/sql-schema/verify-database.sql
```

Or double-click: `check-database.bat`

## What You Should See:

### ✅ Triggers (8 total):
- after_post_like_insert
- after_post_like_delete
- after_comment_insert
- after_comment_delete
- after_comment_like_insert
- after_comment_like_delete
- after_post_insert
- after_connection_accepted

### ✅ Stored Procedures (4 total):
- GetUserFeed
- GetUserActivity
- GetMutualConnectionsCount
- GetConnectionSuggestions

### ✅ Tables:
- USER_ACTIVITY table exists
- USERS table has PHONE field

## If Missing Anything:

Run this to install everything:
```bash
mysql -u root -pviper professional_network < backend/sql-schema/migration-add-triggers.sql
```

## Quick Test:

```sql
-- Check triggers
SHOW TRIGGERS FROM professional_network;

-- Check procedures
SHOW PROCEDURE STATUS WHERE Db = 'professional_network';

-- Check USER_ACTIVITY
SELECT COUNT(*) FROM USER_ACTIVITY;

-- Check PHONE field
DESCRIBE USERS;
```

## Files Created:

1. ✅ `verify-database.sql` - Verification script
2. ✅ `migration-add-triggers.sql` - Installation script (already exists)
3. ✅ `check-database.bat` - Windows batch file for easy checking
4. ✅ `DATABASE_SETUP_GUIDE.md` - Complete guide

Just run the verification script to see what you have!
