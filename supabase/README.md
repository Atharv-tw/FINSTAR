# FINSTAR - Supabase Edge Functions Backend

This directory contains Supabase Edge Functions that handle server-side logic for the FINSTAR app, replacing Firebase Cloud Functions to work within the free tier.

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Supabase Edge Functions│────▶│    Firebase     │
│  (Frontend)     │     │  (Server-side logic)    │     │   Firestore     │
└─────────────────┘     └─────────────────────────┘     └─────────────────┘
        │                         │
        │                         ▼
        │                ┌─────────────────┐
        └───────────────▶│  Firebase Auth  │
                         └─────────────────┘
```

## Functions Overview

### Game Submissions (P0 - Critical)
| Function | Endpoint | Description |
|----------|----------|-------------|
| `submit-life-swipe` | POST | Submit Life Swipe game results |
| `submit-budget-blitz` | POST | Submit Budget Blitz game results |
| `submit-quiz-battle` | POST | Submit Quiz Battle game results |
| `submit-market-explorer` | POST | Submit Market Explorer game results |

### Learning & Progress (P1)
| Function | Endpoint | Description |
|----------|----------|-------------|
| `complete-lesson` | POST | Complete lesson and award XP/coins |
| `daily-checkin` | POST | Daily check-in for streaks |
| `check-achievements` | POST | Check and unlock achievements |
| `update-leaderboard` | POST | Update user's leaderboard position |

### Scheduled Tasks (P1)
| Function | Endpoint | Description |
|----------|----------|-------------|
| `generate-daily-challenges` | POST | Generate 3 daily challenges |
| `reset-streaks` | POST | Reset broken streaks (scheduled) |

### Social & Notifications (P2)
| Function | Endpoint | Description |
|----------|----------|-------------|
| `search-users` | POST | Search users by display name |
| `send-notification` | POST | Send push notification to a user |
| `quiz-matchmaking` | POST | Multiplayer quiz match management |

## Setup Instructions

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create an account
2. Create a new project (free tier available)
3. Note your project URL: `https://your-project-id.supabase.co`

### 2. Configure Firebase Service Account

The Edge Functions need Firebase Admin SDK credentials to access Firestore:

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download the JSON file

### 3. Set Environment Variables

In Supabase Dashboard → Settings → Edge Functions → Environment Variables:

```bash
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=<base64-encoded-private-key>
CRON_SECRET=your-random-secret-for-scheduled-tasks
```

To encode the private key:
```bash
# On macOS/Linux
cat path/to/serviceAccountKey.json | jq -r '.private_key' | base64

# Or in Node.js
const key = require('./serviceAccountKey.json').private_key;
console.log(Buffer.from(key).toString('base64'));
```

### 4. Deploy Functions

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-id

# Deploy all functions
supabase functions deploy

# Or deploy individual function
supabase functions deploy submit-life-swipe
```

### 5. Update Flutter App

1. Open `lib/config/supabase_config.dart`
2. Replace the project URL:
   ```dart
   static const String projectUrl = 'https://your-actual-project-id.supabase.co';
   ```

### 6. Set Up Scheduled Tasks

Use GitHub Actions or a cron service to call scheduled functions:

**.github/workflows/scheduled-tasks.yml**
```yaml
name: Scheduled Tasks

on:
  schedule:
    # Reset streaks at 4:00 AM IST (22:30 UTC previous day)
    - cron: '30 22 * * *'
    # Update leaderboard daily at midnight IST (18:30 UTC previous day)
    - cron: '30 18 * * *'

jobs:
  reset-streaks:
    runs-on: ubuntu-latest
    steps:
      - name: Reset Streaks
        run: |
          curl -X POST "${{ secrets.SUPABASE_URL }}/functions/v1/reset-streaks" \
            -H "Content-Type: application/json" \
            -d '{"secret": "${{ secrets.CRON_SECRET }}"}'

  update-leaderboard:
    runs-on: ubuntu-latest
    steps:
      - name: Update Leaderboard
        run: |
          curl -X POST "${{ secrets.SUPABASE_URL }}/functions/v1/update-leaderboard" \
            -H "Content-Type: application/json" \
            -d '{"mode": "full", "secret": "${{ secrets.CRON_SECRET }}"}'
```

Add secrets to your GitHub repository:
- `SUPABASE_URL`: Your Supabase project URL
- `CRON_SECRET`: Same secret set in Supabase environment

## Local Development

### Run Functions Locally

```bash
# Start local development server
supabase functions serve

# Test a function
curl -X POST http://localhost:54321/functions/v1/submit-life-swipe \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <firebase-id-token>" \
  -d '{"seed": 12345, "allocations": {"needs": 5000, "wants": 3000, "savings": 1500, "invest": 500}, "score": 750}'
```

### Environment Variables for Local Development

Create `.env.local` in the supabase directory:
```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account-email
FIREBASE_PRIVATE_KEY=your-base64-encoded-key
CRON_SECRET=test-secret
```

## API Reference

### Authentication

All functions (except scheduled tasks) require Firebase ID token:

```
Authorization: Bearer <firebase-id-token>
```

### submit-life-swipe

**Request:**
```json
{
  "seed": 12345,
  "allocations": {
    "needs": 5000,
    "wants": 3000,
    "savings": 1500,
    "invest": 500
  },
  "score": 750,
  "eventChoices": []
}
```

**Response:**
```json
{
  "success": true,
  "xpEarned": 35,
  "coinsEarned": 42,
  "newLevel": 5,
  "newXp": 4500,
  "leveledUp": false,
  "savingsRate": 0.2
}
```

### submit-budget-blitz

**Request:**
```json
{
  "score": 1500,
  "level": 8,
  "correctDecisions": 25,
  "totalDecisions": 30
}
```

### submit-quiz-battle

**Request:**
```json
{
  "correctAnswers": 8,
  "totalQuestions": 10,
  "timeBonus": 25,
  "isWinner": true
}
```

### submit-market-explorer

**Request:**
```json
{
  "portfolioValue": 12500.50,
  "initialValue": 10000.00,
  "portfolio": {
    "stocks": 5000,
    "bonds": 3000,
    "crypto": 2000,
    "cash": 2500.50
  },
  "decisionsCount": 15
}
```

### daily-checkin

**Request:** (empty body)

**Response:**
```json
{
  "success": true,
  "streakDays": 7,
  "xpEarned": 50,
  "coinsEarned": 25,
  "milestone": 7,
  "milestoneBonus": {"xp": 100, "coins": 50}
}
```

### check-achievements

**Request:**
```json
{
  "trigger": "game"
}
```

**Response:**
```json
{
  "success": true,
  "newlyUnlocked": [
    {
      "id": "games_10",
      "name": "Getting Started",
      "xpReward": 500,
      "coinReward": 200
    }
  ],
  "totalXpReward": 500,
  "totalCoinReward": 200
}
```

### search-users

**Request:**
```json
{
  "query": "john",
  "limit": 20
}
```

**Response:**
```json
{
  "success": true,
  "users": [
    {
      "uid": "user123",
      "displayName": "John Doe",
      "avatarUrl": "https://...",
      "level": 5,
      "isFriend": false,
      "isPending": true
    }
  ],
  "count": 1
}
```

### send-notification

**Request:**
```json
{
  "targetUserId": "user123",
  "title": "Friend Request",
  "body": "John wants to be your friend!",
  "type": "friend_request",
  "data": {"fromUserId": "user456"}
}
```

**Response:**
```json
{
  "success": true,
  "notificationId": "notif123",
  "tokenCount": 2,
  "message": "Notification queued for delivery"
}
```

### quiz-matchmaking

**Find or Create Match:**
```json
{
  "action": "find_match",
  "category": "general"
}
```

**Join Existing Match:**
```json
{
  "action": "join_match",
  "matchId": "match123"
}
```

**Set Ready:**
```json
{
  "action": "ready",
  "matchId": "match123"
}
```

**Submit Answer:**
```json
{
  "action": "submit_answer",
  "matchId": "match123",
  "questionIndex": 0,
  "answer": 2
}
```

**Leave Match:**
```json
{
  "action": "leave_match",
  "matchId": "match123"
}
```

**Response (Match Found):**
```json
{
  "success": true,
  "action": "joined",
  "matchId": "match123",
  "opponent": {
    "uid": "user456",
    "displayName": "Jane Doe",
    "avatarUrl": "https://..."
  }
}
```

## Error Handling

All functions return consistent error format:

```json
{
  "success": false,
  "error": "Error message description"
}
```

HTTP Status Codes:
- `200` - Success
- `400` - Bad Request (invalid input)
- `401` - Unauthorized (missing/invalid auth)
- `404` - Not Found (user/resource not found)
- `500` - Internal Server Error

## Monitoring

View function logs in Supabase Dashboard:
1. Go to Edge Functions
2. Select a function
3. View Logs tab

## Cost Considerations

Supabase Free Tier includes:
- 500,000 Edge Function invocations/month
- 500 MB database storage
- No cold start issues (always warm)

For most apps, this is more than sufficient for the free tier.

## Troubleshooting

### "User not authenticated" Error
- Ensure Firebase ID token is valid
- Token might be expired (refresh it)

### "FIREBASE_PRIVATE_KEY" Error
- Verify the key is base64 encoded
- Check no extra whitespace in environment variable

### "User not found" Error
- User profile might not exist in Firestore
- Create user document on first login

### CORS Issues
- Functions include CORS headers
- If issues persist, check browser console for details
