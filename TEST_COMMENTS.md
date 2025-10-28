# Testing Comments - Debug Guide

## Step 1: Check Database

Run this SQL query to see if comments have content:

```sql
USE professional_network;
SELECT COMMENT_ID, POST_ID, USER_ID, CONTENT, CREATED_AT 
FROM COMMENTS 
ORDER BY CREATED_AT DESC 
LIMIT 10;
```

**Expected:** You should see CONTENT column with text

**If CONTENT is NULL/empty:** The comments were added without content (bug in old code)

## Step 2: Test Backend API

Open your browser and go to:
```
http://localhost:5000/api/posts/1/comments
```
(Replace `1` with an actual POST_ID that has comments)

**Expected Response:**
```json
[
  {
    "COMMENT_ID": 1,
    "POST_ID": 1,
    "USER_ID": 2,
    "CONTENT": "This is a test comment",
    "LIKES_COUNT": 0,
    "CREATED_AT": "2024-01-15T10:30:00.000Z",
    "UPDATED_AT": "2024-01-15T10:30:00.000Z",
    "F_NAME": "John",
    "L_NAME": "Doe",
    "PROFILE_PIC_URL": null
  }
]
```

**Check:** Does `CONTENT` field have text?

## Step 3: Test Frontend

1. Open your app in browser
2. Press F12 to open DevTools
3. Go to Console tab
4. Click Comment button on any post
5. Look for: `Loaded comments: [...]`

**What to check:**
- Is the array empty `[]`?
- Do objects have `CONTENT` field?
- Is `CONTENT` value empty or has text?

## Step 4: Visual Test

1. Click Comment on a post
2. Type: "Test comment 123"
3. Press Enter or click Send
4. **Look for:**
   - Your avatar
   - Your name
   - The text "Test comment 123"
   - Timestamp (e.g., "a few seconds ago")

## Common Issues & Fixes

### Issue 1: Comments show but no text
**Cause:** CONTENT field is empty in database
**Fix:** Delete old comments and add new ones

```sql
-- Delete comments without content
DELETE FROM COMMENTS WHERE CONTENT IS NULL OR CONTENT = '';
```

### Issue 2: "Loading comments..." never stops
**Cause:** API request failing
**Fix:** Check Network tab in DevTools for errors

### Issue 3: Can't add comments
**Cause:** Not logged in or token expired
**Fix:** Logout and login again

### Issue 4: Comments disappear after refresh
**Cause:** Database trigger not working
**Fix:** Check if triggers exist:

```sql
SHOW TRIGGERS LIKE 'COMMENTS';
```

## Quick Fix: Add Test Comment Directly

```sql
-- Add a test comment (replace IDs with real ones)
INSERT INTO COMMENTS (POST_ID, USER_ID, CONTENT) 
VALUES (1, 1, 'This is a test comment to verify display');

-- Check if it was added
SELECT * FROM COMMENTS ORDER BY CREATED_AT DESC LIMIT 1;
```

Then refresh your app and click Comment button on that post.

## Expected Behavior

When working correctly:
1. Click Comment button → Section expands
2. See textarea with "Write a comment..." placeholder
3. Type comment and press Enter
4. Comment appears immediately with:
   - Your profile picture
   - Your name (clickable)
   - Comment text
   - Timestamp
   - Delete button (if it's your comment)

## Still Not Working?

Share these details:
1. Screenshot of browser console when clicking Comment
2. Screenshot of Network tab showing the API response
3. Result of SQL query: `SELECT * FROM COMMENTS LIMIT 5;`
4. Any error messages in backend console

The code is correct, so it's likely a data issue or environment issue!
