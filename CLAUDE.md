# FINSTAR App - Project Context

## App Overview

FINSTAR is a **financial literacy learning app** for young adults in India. It gamifies personal finance education through interactive games, lessons, and social features.

**Tech Stack:**
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Realtime Database, Auth, FCM)
- **Image Storage:** Cloudinary (free tier)
- **Architecture:** Client-side logic (no Cloud Functions - free tier compatible)

---

## Core Features

### 1. Learning System
- **Modules:** Budgeting, Saving, Investing, Credit, Insurance, Taxes
- **Lessons:** Interactive content with text, images, and quizzes
- **Progress Tracking:** Per-lesson completion stored in Firestore
- **Location:** `lib/features/learning/`, `lib/data/learning_modules_data.dart`

### 2. Games
| Game | Description | Location |
|------|-------------|----------|
| **Life Swipe** | Budget allocation simulator with life events | `lib/features/games/life_swipe/` |
| **Quiz Battle** | Timed financial literacy quiz | `lib/features/games/quiz_battle/` |
| **Market Explorer** | Stock market simulation | `lib/features/games/market_explorer/` |
| **Budget Blitz** | Quick budget decision game | `lib/features/games/budget_blitz/` |

### 3. Gamification
- **XP & Levels:** Earned from games, lessons, daily activities
- **Coins:** In-app currency for store purchases
- **Streaks:** Daily check-in rewards
- **Achievements:** Milestone-based unlockables
- **Leaderboard:** Monthly rankings by XP

### 4. Social
- **Friends System:** Add friends, view their progress
- **Multiplayer Quiz:** Real-time 1v1 quiz battles (uses Realtime Database)

### 5. Store
- Cosmetic items purchasable with coins
- Avatar customization

---

## Architecture

### Free Tier Design (No Cloud Functions)

All business logic runs **client-side** in `lib/services/game_logic_service.dart`:

```
┌─────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│    Firestore    │
│  (Client-side   │     │  (Database)     │
│   logic)        │     └─────────────────┘
└─────────────────┘              │
        │                        ▼
        │              ┌─────────────────┐
        └─────────────▶│ Realtime DB     │
                       │ (Multiplayer)   │
                       └─────────────────┘
```

### Key Services

| File | Purpose |
|------|---------|
| `lib/services/game_logic_service.dart` | All game submissions, XP/coin awards, achievements |
| `lib/services/firebase_service_free.dart` | Firebase initialization, auth, profile management |
| `lib/services/notification_service.dart` | FCM push notifications (direct Firestore) |
| `lib/services/cloudinary_service.dart` | Avatar image uploads |

### Data Flow for Game Submission
1. User completes game → Client calculates score
2. `game_logic_service.dart` validates and calculates rewards
3. Firestore transaction updates user profile + game progress
4. Achievement check runs locally
5. Daily challenge progress updated if applicable

---

## Database Structure

### Firestore Collections
```
users/{uid}
  ├── displayName, email, xp, level, coins, streakDays
  ├── progress/{gameId} - Game high scores and stats
  ├── achievements/{id} - Unlocked achievements
  ├── dailyChallenges/{id} - Today's challenges
  ├── learningProgress/{lessonId} - Completed lessons
  ├── inventory/{itemId} - Purchased items
  ├── fcmTokens/{token} - Push notification tokens
  └── friendRequests/{id} - Friend requests

leaderboards/{seasonId} - Monthly rankings
store/items/all/{itemId} - Store items
```

### Realtime Database
```
quizMatches/{matchId} - Live multiplayer quiz state
rooms/{roomId} - Quiz room for real-time sync
leaderboards/live - Real-time leaderboard
```

---

## Current Status

### Fully Working
- [x] User authentication (Google, Email)
- [x] All 4 games with scoring and rewards
- [x] Learning modules with lessons
- [x] XP, Coins, Levels system
- [x] Daily streaks and check-in
- [x] Achievements system
- [x] Store and purchases
- [x] Leaderboard display
- [x] Friends system
- [x] Push notification setup (FCM tokens stored)
- [x] Avatar upload via Cloudinary

### Needs Testing
- [ ] Multiplayer quiz matchmaking
- [ ] Daily challenges generation (client-side)
- [ ] Push notification delivery (requires FCM server key)

---

## Future Plans

### High Priority
1. **Daily Challenges (Client-Side)**
   - Generate 3 random challenges when user opens app (if none exist for today)
   - Types: playGames, earnXp, earnCoins, completeLesson, perfectScore
   - Location: Add to `game_logic_service.dart`

2. **Streak Reset Check**
   - Check on app open if streak should reset (last active > 1 day ago)
   - Location: Add to `firebase_service_free.dart` initialization

3. **Leaderboard Update**
   - Update user's leaderboard entry on each game completion
   - Location: Add to `game_logic_service.dart` after game submissions

4. **User Search**
   - Search users by display name for adding friends
   - Add Firestore query with prefix matching

### Medium Priority
5. **Budget Blitz Backend Integration**
   - Game exists but may not save progress properly
   - Verify `submitBudgetBlitz()` is called from result screen

6. **Offline Support**
   - Implement `local_storage_service.dart` for offline caching
   - Queue game results when offline, sync when online

7. **Analytics Dashboard**
   - Track user engagement, popular games, completion rates
   - Use Firebase Analytics events

### Low Priority
8. **Premium Features**
   - Ad-free experience
   - Exclusive cosmetics
   - Payment integration (Razorpay for India)

9. **Admin Panel**
   - Web dashboard for content management
   - Add/edit lessons without app update
   - View user statistics

10. **Localization**
    - Hindi language support
    - Regional language options

---

## Cloud Functions (Not Deployed)

The `functions/index.js` file contains Cloud Functions code that **requires Blaze plan**.

**If you upgrade to Blaze later**, these functions are ready:
- `submitLifeSwipe`, `submitQuizBattle`, `submitMarketExplorer`
- `generateDailyChallenges` (scheduled)
- `updateLeaderboard` (scheduled)
- `resetStreaks` (scheduled)
- `sendStreakReminders`, `sendDailyChallengeReminders`
- Multiplayer quiz functions
- FCM notification triggers

**Current approach:** All equivalent logic is in `game_logic_service.dart` (client-side).

---

## Environment Setup

### Firebase Project
- Project ID: `finstar-prod`
- Region: `asia-south1` (Mumbai)
- Plan: Spark (Free)

### Required Config Files
- `lib/firebase_options.dart` - Firebase config (auto-generated)
- `lib/config/cloudinary_config.dart` - Cloudinary credentials
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

### Running the App
```bash
flutter pub get
flutter run
```

### Deploying (if upgrading to Blaze)
```bash
cd functions && npm install
firebase deploy --only "functions"
```

---

## Key Files Reference

| File | Description |
|------|-------------|
| `lib/main.dart` | App entry point |
| `lib/app/router.dart` | Navigation routes (GoRouter) |
| `lib/providers/` | Riverpod state management |
| `lib/services/game_logic_service.dart` | **Core backend logic** |
| `lib/features/home/basic_home_screen.dart` | Home screen |
| `lib/data/learning_modules_data.dart` | All lesson content |
| `functions/index.js` | Cloud Functions (not deployed) |
| `firestore.rules` | Database security rules |
| `database.rules.json` | Realtime DB security rules |
