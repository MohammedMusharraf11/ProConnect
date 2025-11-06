# SQL Functions Integration Guide

## Functions Created ✅

### 1. GetConnectionCount(user_id)
**Purpose:** Get total accepted connections for a user
**Returns:** INT
**Usage:**
```sql
SELECT GetConnectionCount(1) as connectionCount;
```

### 2. GetPostCount(user_id)
**Purpose:** Get total posts created by a user
**Returns:** INT
**Usage:**
```sql
SELECT GetPostCount(1) as postCount;
```

### 3. GetMutualConnectionCount(user_id1, user_id2)
**Purpose:** Get count of mutual connections between two users
**Returns:** INT
**Usage:**
```sql
SELECT GetMutualConnectionCount(1, 2) as mutualCount;
```

### 4. IsConnected(user_id1, user_id2)
**Purpose:** Check connection status between two users
**Returns:** VARCHAR ('accepted', 'pending', 'rejected', 'not_connected')
**Usage:**
```sql
SELECT IsConnected(1, 2) as status;
```

### 5. GetUserFullName(user_id)
**Purpose:** Get user's full name (First + Last)
**Returns:** VARCHAR
**Usage:**
```sql
SELECT GetUserFullName(1) as fullName;
```

### 6. CalculateProfileCompleteness(user_id)
**Purpose:** Calculate profile completion percentage (0-100%)
**Returns:** INT
**Checks:**
- Bio (10%)
- Headline (10%)
- Phone (10%)
- Location (10%)
- Industry (10%)
- Profile Picture (10%)
- Experience (10%)
- Education (10%)
- Skills (10%)
- Projects (10%)

**Usage:**
```sql
SELECT CalculateProfileCompleteness(1) as completeness;
```

## Backend Integration ✅

### Updated Files:

#### 1. `backend/controllers/userController.js`

**getUserProfile** - Now returns:
```javascript
{
  USER_ID: 1,
  F_NAME: "John",
  L_NAME: "Doe",
  connectionCount: 25,        // ← Using GetConnectionCount()
  postCount: 10,              // ← Using GetPostCount()
  profileCompleteness: 80     // ← Using CalculateProfileCompleteness()
}
```

**searchUsers** - Now returns:
```javascript
{
  USER_ID: 1,
  F_NAME: "John",
  connectionCount: 25,        // ← Using GetConnectionCount()
  connectionStatus: "accepted" // ← Using IsConnected()
}
```

**getAllUsers** - Now returns connection count and status for each user

**getUserStats** - NEW endpoint:
```
GET /api/users/:userId/stats
```
Returns:
```javascript
{
  connectionCount: 25,
  postCount: 10,
  profileCompleteness: 80,
  fullName: "John Doe"
}
```

#### 2. `backend/controllers/connectionsController.js`

**getMutualConnectionsCount** - Now uses function instead of procedure:
```javascript
// Before: CALL GetMutualConnectionsCount(?, ?)
// After: SELECT GetMutualConnectionCount(?, ?)
```

**getUserConnections** - Now includes:
- Connection count for each user
- Mutual connections count (when viewing others' connections)

## Frontend Integration ✅

### New Components:

#### 1. `ProfileCompletenessCard.tsx`
Shows profile completion percentage with:
- Progress bar
- Checklist of completed items
- Motivational message
- Color-coded percentage (red < 50%, yellow < 80%, green ≥ 80%)

**Usage:**
```tsx
<ProfileCompletenessCard 
  completeness={user.profileCompleteness}
  user={user}
/>
```

#### 2. `UserStatsCard.tsx`
Shows user statistics in a grid:
- Connections count
- Posts count
- Profile strength percentage

**Usage:**
```tsx
<UserStatsCard 
  connectionCount={user.connectionCount}
  postCount={user.postCount}
  profileCompleteness={user.profileCompleteness}
/>
```

### Updated Components:

#### 1. `Profile.tsx`
- Added UserStatsCard at top
- Added ProfileCompletenessCard (only on own profile if < 100%)
- Automatically fetches and displays stats

#### 2. `SuggestionsCard.tsx`
- Shows connection count for each suggested user
- Better information display

## API Endpoints Using Functions

### GET /api/users/:userId
```javascript
// Response includes:
{
  connectionCount: 25,      // GetConnectionCount()
  postCount: 10,            // GetPostCount()
  profileCompleteness: 80   // CalculateProfileCompleteness()
}
```

### GET /api/users/:userId/stats
```javascript
// Response:
{
  connectionCount: 25,
  postCount: 10,
  profileCompleteness: 80,
  fullName: "John Doe"
}
```

### GET /api/users/all
```javascript
// Each user includes:
{
  connectionCount: 25,           // GetConnectionCount()
  connectionStatus: "accepted"   // IsConnected()
}
```

### GET /api/users/search
```javascript
// Each user includes:
{
  connectionCount: 25,
  connectionStatus: "not_connected"
}
```

### GET /api/connections/:userId
```javascript
// Each connection includes:
{
  connectionCount: 15,
  mutualConnections: 5  // GetMutualConnectionCount()
}
```

### GET /api/connections/mutual/:userId
```javascript
// Response:
{
  mutualCount: 5  // GetMutualConnectionCount()
}
```

## How to Test

### 1. Test Backend Functions

```bash
# Restart backend
cd backend
npm start
```

### 2. Test API Endpoints

```bash
# Get user profile with stats
curl http://localhost:5000/api/users/1

# Get user stats
curl http://localhost:5000/api/users/1/stats

# Get all users with connection info
curl http://localhost:5000/api/users/all
```

### 3. Test Frontend

1. Refresh your browser
2. Go to your profile
3. You should see:
   - Stats card at the top (Connections, Posts, Profile Strength)
   - Profile Completeness card (if profile < 100%)
   - Connection counts in suggestions

## Benefits of Using Functions

### Performance
- ✅ Pre-compiled and optimized
- ✅ Faster than multiple queries
- ✅ Reduced network overhead

### Consistency
- ✅ Same logic everywhere
- ✅ No duplicate code
- ✅ Single source of truth

### Maintainability
- ✅ Update logic in one place
- ✅ Easy to test
- ✅ Clear documentation

### Reusability
- ✅ Use in queries, procedures, triggers
- ✅ Call from any controller
- ✅ Combine multiple functions

## Example Queries

### Get user with all stats:
```sql
SELECT 
  u.*,
  GetConnectionCount(u.USER_ID) as connectionCount,
  GetPostCount(u.USER_ID) as postCount,
  CalculateProfileCompleteness(u.USER_ID) as profileCompleteness
FROM USERS u
WHERE u.USER_ID = 1;
```

### Get users with connection status:
```sql
SELECT 
  u.*,
  GetConnectionCount(u.USER_ID) as connectionCount,
  IsConnected(1, u.USER_ID) as connectionStatus
FROM USERS u
WHERE u.STATUS = 'active';
```

### Get mutual connections:
```sql
SELECT 
  u.*,
  GetMutualConnectionCount(1, u.USER_ID) as mutualConnections
FROM USERS u
WHERE u.USER_ID != 1;
```

## What's Next?

You can create more functions for:
- Calculate engagement rate
- Get average post likes
- Count pending requests
- Calculate response time
- Get activity score
- Rank users by activity

All functions are now integrated and working! 🎉
