# 🪙 Finstar — High‑Level Design (HLD) v1.0 (EXTENDED)

**Tagline:** *Learn Money. Play Smart.*  
**Platforms:** Android, iOS  
**Primary Stack:** Flutter + Flame (2D mini‑games), Firebase (Auth, Firestore, RTDB, Storage, Functions), Rive/Lottie for animation  
**Optional Games Stack (Phase 3+):** Unity‑as‑module for 3D scenes or advanced physics

---

## 0. Document Purpose & Readers
This HLD defines *what* we’re building and *how* at a system and design level. It’s implementation‑ready for engineers, designers, and PMs. Detailed enough to create epics, tickets, and acceptance tests.

---

## 1. Objectives, Scope, KPIs

### 1.1 Goals
- Teach core finance concepts to 14–19 through **playable learning**.
- Single identity and **unified progression**: Coins, XP, Levels, Badges, Streaks.
- Low‑ops, **serverless** backend with real‑time features for quizzes & leaderboards.

### 1.2 Non‑Goals (MVP)
- Real‑money investing/KYC.  
- DM/chat features (beyond friends & leaderboards).  
- Parent/teacher dashboards (arrive after MVP).

### 1.3 Success Metrics (12 weeks post‑launch)
- D1 retention ≥ **40%**, D7 ≥ **18%**, D30 ≥ **8%**.
- Avg. session length ≥ **9 min**, 2.5+ games/session.  
- **>70%** lesson completion rate for users who start a lesson.  
- Crash‑free sessions ≥ **99.2%**.  
- P95 dashboard data ready < **400 ms** on 4G.

---

## 2. Personas & Key Use Cases

### 2.1 Personas
- **Teen Learner** (primary): wants fun loops, visible progress, cosmetics.
- **Casual Player**: quick sessions; motivated by leaderboards & streaks.
- **Content Admin** (internal): manages lessons, quiz bank, store items.
- **Parent/Guardian** (phase 4): receives optional progress summaries.

### 2.2 Core Use Cases
- Sign up, onboard, customize avatar.  
- Play **Life Swipe** (monthly budget sim).  
- Play **Quiz Battle** (solo/multiplayer).  
- Play **Market Explorer** (5‑year sim).  
- Take a lesson; pass micro‑quiz; earn rewards.  
- Browse badges & shop; purchase cosmetics.  
- Add friends; view leaderboards.  
- Daily check‑in streak.

---

## 3. Experience Map & Critical Flows

### 3.1 First‑Time User Flow
1) Install → Splash → Onboarding slides.  
2) Auth (Google/Email) → Create `users/{uid}` with starter pack.  
3) Home dashboard → Guided tooltip to **Life Swipe** → Complete first run → Coins/XP.  
4) Prompt: take **Lesson 1** → micro‑quiz → reward → streak prompt.

### 3.2 Re‑Engagement Flow
- Daily push: “Streak reward available + rotating challenge (e.g., ‘Save ≥20% today’).”  
- Weekly: “New lesson drop + double XP weekend.”  
- Seasonal: limited‑time badge/skin.

### 3.3 Error/Edge Flows
- Offline: allow lessons and Life Swipe; queue rewards.  
- Auth failure: retry with backoff; continue guest mode (limited).  
- Version gate via Remote Config (`minSupportedVersion`).

---

## 4. Functional Requirements (Detailed)

### 4.1 Authentication & Profile
- Providers: Email/Password, Google (Apple optional).  
- Profile fields: `displayName`, `avatar`, `ageBracket`, progression counters.  
- Guest mode allowed; must upgrade to save cloud progress.  
- **Acceptance:** New user receives starter coins (e.g., 200), XP=0, Level=0, streak=0.

### 4.2 Home Dashboard
- Summary: Coins, XP, Level, Streak, Rank snapshot.  
- CTAs: **Play Games**, **Learn**, **Rewards**, **Friends**.  
- Surfaces weekly challenge and active events.  
- **Acceptance:** All counters reflect server truth within <500 ms; shimmer while loading.

### 4.3 Life Swipe (Game #1)
- Player allocates ₹10,000 across jars: `needs`, `wants`, `savings`, `invest`.  
- Random life events influenced by seeded RNG and player choices.  
- End‑of‑month summary: surplus, penalties, bonus for emergency fund ≥x%.  
- Rewards via **Function** (server‑validated).  
- **Acceptance:** Server rejects payload if allocations ≠ 10,000 total, or seed mismatch.

**Event Pools (examples)**
- Negative: “Phone repair ₹2,500”, “Tuition book ₹800”.  
- Positive: “Festival gift ₹1,000”, “Part‑time ₹2,000”.  
- Neutral/Choice: “Class trip ₹1,200 — join?”

**Scoring (illustrative)**
```
baseXP = 20
savingsBonus = clamp( floor(savingsPct/5) * 2 , 0, 12 )
emergencyFundBonus = emergencyFundMet ? 8 : 0
penalty = overspend ? -6 : 0
XP = max(0, baseXP + savingsBonus + emergencyFundBonus + penalty)
Coins = floor(XP * 1.2)
```

### 4.4 Market Explorer (Game #2)
- Choose allocation across islands: FD, SIP, Stocks, Crypto.  
- Simulate 60 ticks (months) with **deterministic seed**; show line chart and portfolio outcome.  
- Teach risk/return via controlled variance bands.  
- **Acceptance:** Same seed and allocation always produce identical curve client‑ and server‑side.

**Return Model (controlled)**
```
For each asset a:
  r_t = mu[a] + sigma[a] * noise(seed, a, t)
  price_t = price_{t-1} * (1 + r_t)
Example params (educational):
  FD:    mu=0.005, sigma=0.0005
  SIP:   mu=0.009, sigma=0.004
  Stocks:mu=0.012, sigma=0.015
  Crypto:mu=0.02,  sigma=0.05
```

### 4.5 Quiz Battle (Game #3)
- **Solo:** local question bank; timer; streak bonuses.  
- **Multiplayer (RTDB):** lobby (≤6), host start, server‑seeded question set, per‑round lock‑in, scoreboard.  
- **Acceptance:** Finalize writes placements; top scores reflected in snapshot leaderboards within 5s.

### 4.6 Learn Modules
- 2–3 min cards: illustration/video + 3–5 micro‑MCQs.  
- Completion unlocks a badge chance (e.g., “First Lesson”).  
- **Acceptance:** Network loss mid‑lesson still allows completion; reward queues persist.

### 4.7 Rewards, Badges, Shop
- View coins/XP; grid of badges; carousel store.  
- Purchase only if coins ≥ price; inventory written to `users/{uid}/inventory`.  
- **Acceptance:** Double‑spend prevented via transactional Function.

### 4.8 Friends & Leaderboards
- Send friend request; accept/decline; reciprocal edges on accept.  
- Leaderboards: daily/weekly/all‑time; top 100 snapshots; self rank.  
- **Acceptance:** Privacy—only `displayName`, avatar, country flag exposed.

### 4.9 Parental Controls (Phase 4)
- Age gate to set `ageBracket`.  
- Optional parent email for activity summaries (weekly).  
- Playtime nudges: >45 min continuous triggers cool‑off suggestion.

---

## 5. Non‑Functional Requirements
- **Performance:** 60 fps animations; P95 dashboard data <400 ms; game screen TTI <800 ms.  
- **Availability:** 99.9% Firebase availability (best‑effort; serverless).  
- **Security:** Least‑privilege rules; App Check; all sensitive mutators via Functions.  
- **Privacy:** Minimal PII; COPPA‑friendly posture (no precise location; no behavioral ads).  
- **Accessibility:** WCAG AA contrast; dynamic type; haptic toggle.  
- **Localization:** EN → HI first; LTR only initially.  
- **Offline:** Read‑through cache + intent queue for rewards.

---

## 6. System Architecture (Logical)
```
Flutter App
  ├─ Feature Screens (Home, Games, Learn, Rewards, Friends, Profile)
  ├─ Shared Clients (Auth, Gamification, Content, Quiz, MarketSim)
  └─ Local Cache (Hive/Isar) + Intent Queue

Firebase
  ├─ Auth (Google, Email)
  ├─ Firestore (profiles, progress, lessons, badges, store, friends, configs)
  ├─ RTDB (quizRooms live state, live leaderboards)
  ├─ Storage (media, avatars, lotties)
  ├─ Cloud Functions (validation, rewards, purchases, leaderboards)
  └─ Scheduler (daily/weekly jobs)

Analytics & Ops
  ├─ Firebase Analytics → BigQuery
  ├─ Crashlytics, Performance Monitoring
  └─ Alerting & Dashboards
```

---

## 7. Client Architecture (Flutter)

### 7.1 Packages & Conventions
- **State:** Riverpod (feature stores + global app store).  
- **Navigation:** `go_router` with typed routes.  
- **Networking:** `cloud_firestore`, `firebase_database`, `cloud_functions`.  
- **Games:** Flame for 2D loops; optional Unity module via platform channels.  
- **Animations:** `rive`, `lottie`, core `Animated*` widgets.  
- **Local:** Hive/Isar (profiles cache, lessons, pending intents).

### 7.2 Folders
```
lib/
 ├─ app/ (bootstrap, router, theme)
 ├─ features/
 │   ├─ auth/
 │   ├─ home/
 │   ├─ games/
 │   │   ├─ life_swipe/
 │   │   ├─ market_explorer/
 │   │   └─ quiz_battle/
 │   ├─ learn/
 │   ├─ rewards/
 │   ├─ leaderboard/
 │   └─ profile/
 ├─ shared/
 │   ├─ services/ (gamification_client.dart, content_client.dart, quiz_client.dart, market_sim_client.dart)
 │   ├─ widgets/
 │   └─ util/ (motion_tokens.dart, formatters.dart)
 └─ data/ (models, adapters)
```

### 7.3 Intent Queue (Offline Mutations)
- Queue entries: `{type, payload, createdAt, retryCount}`.  
- Types: `lifeSwipeResult`, `lessonComplete`, `dailyCheckIn`, `purchaseItem`.  
- Retries: exponential backoff (2^n secs, max 5m).  
- Conflict: server‑wins for `coins/xp/level`.

---

## 8. Data Model & Storage

### 8.1 Firestore (collections)
- `users/{uid}`
  - `displayName:string`  
  - `ageBracket:enum('14-15','16-17','18-19')`  
  - `coins:int`, `xp:int`, `level:int`  
  - `streak:{current:int, lastCheckin:timestamp}`  
  - `avatar:{skin:string, theme:string}`  
  - `createdAt:timestamp`
- `users/{uid}/progress/{doc}`
  - `learn:{[lessonId]: {completedAt, score}}`  
  - `lifeSwipe:{bestScore:int, lastSeed:int, history:[…]}`  
  - `marketExplorer:{bestROI:float, lastSeed:int}`
- `badges/{badgeId}`: `{name, criteria:{type:string, params:{}}, rarity, iconPath}`
- `lessons/{lessonId}`: `{title, topic, durationSec, mediaPath, quiz:[{q, options[], answerIndex}], xpReward:int, coinReward:int, version:int, isActive:bool}`
- `store/items/{itemId}`: `{type:'avatarSkin'|'powerup', priceCoins:int, payload:{}, iconPath}`
- `friends/{uid}/edges/{friendUid}`: `{status:'pending'|'accepted', updatedAt}`
- `configs/app` (singleton): remote toggles, multipliers, minSupportedVersion.

**Indexes**
- Composite on `friends.edges` (`status`, `updatedAt`).  
- `lessons.isActive=true` filter index.

### 8.2 Realtime Database
- `/quizRooms/{roomId}`: `{status, hostUid, players/{uid:{name, avatar, ready, score}}, tick, currentQuestionIndex, questionSeed}`  
- `/leaderboards/{scope}/{period}`: rolling live aggregates for fast UI.

### 8.3 Cloud Storage
- `/lessons/{lessonId}/*` media (mp4/webm, json, images).  
- `/avatars/*` (Rive/Lottie/PNG).  
- `/sfx/*` (short mp3/wav).

### 8.4 Data Retention
- Quiz rooms TTL: 48h (Function cleanup).  
- Old leaderboard snapshots > 90d → archive or delete.  
- Analytics via BigQuery indefinite (aggregate only).

---

## 9. Cloud Functions – API Contracts

> All mutating calls are **callable Functions**; requests validated with App Check tokens.  
> Idempotency via request `nonce`.

### 9.1 `postLifeSwipeResult`
**in** `{ seed:int, month:int, allocations:{needs:int,wants:int,savings:int,invest:int}, events:[{id,action}], score:int, nonce }`  
**out** `{ coinsDelta:int, xpDelta:int, badgesAwarded:[id], totals:{coins,xp,level}, serverHash }`  
**Validations**: sum(allocations)=10000; seed replay‑protection for 10 min window; score bounds.

### 9.2 `issueDailyCheckin`
**in** `{ nonce }`  
**out** `{ streakLen:int, coinsDelta:int, xpDelta:int }`  
Idempotent per UTC day.

### 9.3 `purchaseItem`
**in** `{ itemId:string, nonce }`  
**out** `{ success:bool, coinsRemaining:int }`  
Transaction: check coins ≥ price; deduct; write inventory.

### 9.4 Quiz Lifecycle
- `createQuizRoom({ mode, topic, difficulty }) → { roomId }`  
- `joinQuizRoom({ roomId }) → { ok }`  
- `startQuiz({ roomId }) → { ok, questionSeed }` (server assigns seed)  
- `submitAnswer({ roomId, qIndex, answerIndex }) → { ok }`  
- `finalizeQuiz({ roomId }) → { placements:[{uid,score}], rewards }`

### 9.5 Leaderboards
- `rebuildLeaderboards({ period:'daily'|'weekly' })` (scheduled) → snapshot to Firestore.

---

## 10. Security & Privacy

### 10.1 Firestore Rules (sketch)
- Users can read/write **their own** docs.  
- Server‑owned fields (`coins`,`xp`,`level`) **write‑only by Functions** (checked via custom claim or request.auth.token.function=true).  
- Lessons/store/badges read‑public; write‑admin only.

### 10.2 RTDB Rules (quizRooms)
- Read: members only.  
- Write: only under `players/{uid}` for self; room state mutations by Functions.

### 10.3 Storage Rules
- Lessons public‑read or token gated; user uploads (avatars) owner‑only.

### 10.4 Threats & Mitigations
- **Client tampering/cheats** → server validation, seed determinism, App Check, rate limiting.  
- **Replay** → nonces + time windows.  
- **Abuse** → friend request daily caps; name profanity filter.  
- **PII** → store minimal; ageBracket only; parent contact optional.

---

## 11. Game State Machines

### 11.1 Life Swipe
`INIT → ALLOCATE_FUNDS (drag) → EVENTS (0..n) → SUMMARY → SUBMIT_RESULT → REWARD → EXIT`
- Guards: allocation sum check; event deck not repeat within run; timer optional.

### 11.2 Market Explorer
`INIT → CHOOSE_ALLOCATION → SIMULATE (60 ticks) → GRAPH_REVIEW → SUBMIT_RESULT → REWARD → EXIT`

### 11.3 Quiz Battle (MP)
`LOBBY (join/ready) → IN_PROGRESS (round 1..N) → SCORING → FINALIZE → EXIT`
- Timeboxed rounds; unanswered = 0; anti‑late submit window 150ms.

---

## 12A. Extended UI/UX Design & Visual System (Nixtio-Inspired)
 REFER TO UI_UX_IMPLEMENTATION.md

## 13. Analytics & Telemetry (Schema)

### 13.1 User Properties
- `age_bracket`, `level`, `has_friends`, `country` (coarse), `has_purchase` (cosmetics only).

### 13.2 Events (examples with params)
- `app_open {version}`  
- `onboarding_complete {duration_sec}`  
- `lesson_view {lessonId, topic}`  
- `lesson_complete {lessonId, score, xp_reward, coin_reward}`  
- `life_swipe_start {seed}`  
- `life_swipe_submit {seed, savings_pct, emergency_met, xp_reward, coin_reward}`  
- `quiz_multi_join {roomId, topic}`  
- `quiz_round_submit {qIndex, correct}`  
- `quiz_multi_end {score, placement}`  
- `store_purchase {itemId, priceCoins}`  
- `streak_checkin {streakLen}`  
- `level_up {newLevel}`

### 13.3 Funnels
- Install → Onboarding → First Game → First Reward → Day‑2 Return.  
- Learn start → Learn complete → Quiz pass.

### 13.4 BigQuery Tables
- `events_*` export; derived tables for retention, LTV (cosmetics only), cohort analyses.

---

## 14. Remote Config & Experimentation
- Keys: `minSupportedVersion`, `xpMultiplier`, `coinMultiplier`, `doubleXPWeekend`, `feature.marketExplorer`, `quizRoomMaxSize`.  
- A/B examples: lesson order, reward multipliers, difficulty curves.

---

## 15. Observability & Ops
- **Crashlytics** gating before release.  
- **Performance Monitoring**: network spans (Functions, Firestore reads).  
- **Synthetic monitors**: ping Functions health hourly.  
- **Alerts**: error rate >2%/h; P95 function latency >1.5s; RTDB disconnect spikes.

---

## 16. CI/CD & Environments
- **Repos:** `app/` (Flutter), `functions/` (TS).  
- **Branches:** `main` (prod), PRs → `staging`.  
- **CI:** lint, unit tests, widget tests, build; deploy to staging Firebase; manual promote to prod.  
- **Release checklist:** version bump, changelog, Firebase App Distribution, Play Console internal, TestFlight.

---

## 17. Test Strategy
- **Unit:** scoring math, RNG determinism, purchase transactions.  
- **Widget:** Home cards, progress bars, loaders (goldens).  
- **Integration:** Auth flows, offline queue replay, rules emulators.  
- **E2E:** First‑time user path; multiplayer quiz happy path.  
- **Load:** 200 concurrent quiz players; Functions cold/warm latencies.  
- **Soak:** 24h simulation to detect memory leaks.

---

## 18. Cost & Scaling Model (Estimates, per 10k MAU)
- **Firestore:** ~3 reads/session (profile, configs, store) + 2 writes (progress/rewards).  
- **RTDB:** only during active MP quiz; avg 5 min/day/user → small.  
- **Functions:** 0–3 calls/session; keep pure compute under 100ms warm.  
- **Storage egress:** lessons compressed; consider adaptive bitrates.

Cost controls: cache aggressively; snapshot leaderboards; prune quiz rooms; batch writes; media lifecycle rules.

---

## 19. Risks & Mitigations
- **Engagement drop:** weekly challenges, seasonal badges, streak forgiveness (1 day pass/week).  
- **Cheating:** server validation, App Check, nonces, bounds.  
- **Ecosystem changes:** keep games modular; Unity fallback for complex scenes.  
- **Costs:** feature flags to disable high‑egress content; RTDB listener caps.

---

## 20. Roadmap & Milestones (with Exit Criteria)

**M1 (3–4 wks) – MVP Core**  
- Auth, Profile, Home  
- **Life Swipe v1** (seeded, validated)  
- Learn (5 lessons)  
- Gamification engine v1  
- Analytics baseline  
**Exit:** complete Life Swipe → rewards → counters update; daily check‑in works.

**M2 (3–4 wks) – Competition**  
- **Quiz Battle MP** (rooms ≤6)  
- Leaderboards (daily snapshot)  
- Friends (request/accept)  
**Exit:** live match end writes placements; rank visible in ≤5s.

**M3 (3–4 wks) – Market & Store**  
- **Market Explorer** (deterministic sim)  
- Shop + cosmetics  
- Advanced badges  
**Exit:** purchase works transactionally; ROI sim reproducible.

**M4 (2–3 wks) – Hardening & Growth**  
- Localization skeleton (EN→HI)  
- Parental controls v1  
- Perf targets & crash‑free ≥99.2%  
**Exit:** perf dashboards green; content pipeline documented.

---

## 21. Open Questions
- Depth of parental reporting (opt‑in email vs in‑app family view)?  
- Avatar economy scope at launch (skins only vs power‑ups)?  
- Seasonal content cadence (monthly vs bi‑weekly)?

---

## 22. Appendices

### 22.1 Example Firestore Rules (illustrative)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function isSelf(uid) { return request.auth != null && request.auth.uid == uid; }

    match /users/{uid} {
      allow read: if isSelf(uid);
      allow create: if isSelf(uid);
      // block direct writes to server fields
      allow update: if isSelf(uid) && !('coins' in request.resource.data ||
                                        'xp' in request.resource.data ||
                                        'level' in request.resource.data);
    }

    match /users/{uid}/progress/{doc} { allow read, write: if isSelf(uid); }
    match /lessons/{id} { allow read: if true; allow write: if request.auth.token.admin == true; }
    match /store/items/{id} { allow read: if true; allow write: if request.auth.token.admin == true; }
    match /friends/{uid}/edges/{friendUid} { allow read: if isSelf(uid); allow create, update: if isSelf(uid); }
  }
}
```

### 22.2 Motion Token JSON (example)
```json
{
  "enter": {"dur": 300, "curve": "easeOutQuad"},
  "exit": {"dur": 200, "curve": "easeInQuad"},
  "tap": {"dur": 80, "curve": "easeOut"},
  "reward": {"dur": 600, "curve": "spring"},
  "slide": {"dur": 450, "curve": "easeInOutCubic"},
  "confetti": {"dur": 800, "curve": "bounceOut"}
}
```

### 22.3 Sample Badge Criteria
```json
[
  {"id":"budget_boss","name":"Budget Boss","criteria":{"type":"savings_pct","min":20},"rarity":"uncommon"},
  {"id":"risk_aware","name":"Risk Aware","criteria":{"type":"low_risk_mix","runs":3},"rarity":"rare"},
  {"id":"quiz_streak_10","name":"Quiz Streak 10","criteria":{"type":"correct_streak","value":10},"rarity":"rare"}
]
```

### 22.4 Error Taxonomy (client)
- `AUTH_xx` (signin, token)  
- `NET_xx` (timeouts, offline)  
- `FUNC_xx` (callable failures)  
- `RULES_xx` (permission denied)  
- `DATA_xx` (invalid payloads)

### 22.5 Release Checklist (abridged)
- Crash‑free ≥99% on internal.  
- P95 Function <1.2s warm.  
- Store description/screenshots updated.  
- Remote Config defaults + rollback plan.  
- Content QA for lessons/quiz bank.

---

## 23. Game Economy & Balancing

### 23.1 Currency Model
- **Soft Currency:** Coins (earn via games/lessons/streaks). Inflate slowly.
- **Progress Currency:** XP → Level. Linear at start, curves mid‑game.
- **Sinks:** Avatar skins, limited‑time cosmetics, power‑ups (non‑pay‑to‑win), streak insurance.

### 23.2 XP/Coins Formulas (v1)
```
level(n) = floor(XP / 100)
lesson_complete: XP=10–25, Coins=XP*1.2
life_swipe: XP= base20 + savingsPct/5*2 + (emergency?8:0) + (overspend?-6:0)
quiz_solo: XP = correct*2 + streak*1
quiz_multi: XP = placement_multiplier*[10..30]
market_explorer: XP = clamp(ROI*100, 0, 40)
```

### 23.3 Economy Halting Rules
- Daily coin cap per user (config in Remote Config).  
- Diminishing returns on repeating the same lesson within 24h.  
- Weekly leaderboard rewards are cosmetic only.

### 23.4 Anti‑Inflation Levers
- Rotate store catalog; time‑limited bundles.  
- Escalating prices for duplicate cosmetic archetypes.  
- Seasonal prestige resets (cosmetics persist; ranks reset).

---

## 24. Notification, CRM & Growth

### 24.1 Push Taxonomy
- **Transactional:** streak ready, purchase receipts, leaderboard placement.  
- **Lifecycle:** nudge to complete Lesson N, win‑back (D3/D7).  
- **Event:** double XP weekend, new badge drop.

### 24.2 Triggering & Rate Limits
- Max 1 push/day; quiet hours 22:00–08:00 local.  
- Win‑back cadence: D3 → D7 → D14, stop if negative signal.

### 24.3 Deep Links
- `finstar://lesson/{id}`, `finstar://play/life-swipe`, `finstar://shop/featured`.  
- UTM passthrough to Analytics.

### 24.4 Referral (Phase 3)
- Invite code grants both sides a cosmetic.  
- Fraud checks: device fingerprint + account age.

---

## 25. Content Ops & CMS Workflow

### 25.1 Authoring Pipeline
- Author lesson JSON + media → PR → content review → staging QA → Remote Config flag → prod.  
- Versioning: `lessons/{lessonId} {version, isActive}`; clients cache by `version`.

### 25.2 Quiz Bank Governance
- Topics, difficulty tiers (E/M/H).  
- Per‑user seen set to avoid repeats within 7 days.  
- Item analysis in BigQuery: discrimination, difficulty, guess rate.

### 25.3 Localization
- i18n keys in ARB/JSON; screenshots for translators.  
- Languages: EN→HI (phase 4 adds more).  
- RTL not supported initially.

---

## 26. Compliance & Privacy
- **Children/Teens posture:** minimize PII; no precise location; COPPA‑like safety even if 13+.  
- Parental email optional; no E2EE messaging; no third‑party ad SDKs.  
- Data retention: quiz rooms 48h; leaderboards 90d; analytics aggregates only in BigQuery.  
- DSR: export/delete upon verified request (Firebase Extensions or Functions callable).

---

## 27. Security Threat Model (STRIDE)
- **Spoofing:** App Check; Firebase Auth tokens; emulator checks.  
- **Tampering:** server‑side validation; signed seeds; Firestore rules.  
- **Repudiation:** request nonces + Cloud Logging; user‑visible history.  
- **Information Disclosure:** least‑privilege; no sensitive fields in client logs.  
- **DoS:** rate‑limit Functions; RTDB fan‑out caps; per‑IP quotas.  
- **Elevation:** Functions run with minimal IAM; no wildcard admin.

---

## 28. Performance Engineering Playbook
- Budgets: home TTI <800ms; P95 function warm <1.2s; cold <2.5s.  
- Profiling tools: Flutter DevTools (raster thread), Flame FPS overlay, Firebase Perf traces.  
- Techniques: image spritesheets; cache Lottie; `TickerMode.off` for hidden tabs; prefetch Firestore doc `users/{uid}` + `configs/app` at boot.

---

## 29. Unity Integration Plan (Phase 3)

### 29.1 Options
- **A) Embedded Library:** Unity as Android/iOS library; launch via platform channels.  
- **B) Deep Link/WebGL:** host scene on CDN; run in webview; postMessage bridge.

### 29.2 Data Handoff
- Input: `{uid, sessionId, seed, difficulty}`.  
- Output: signed payload `{score, metrics, seed, ts, sig}` → `postUnityResult` Function.

### 29.3 Build & CI
- Unity build pipeline (Cloud Build or GitHub runners).  
- Artifact attached to app repo; semantic versioning `unityScene@1.2.0`.

---

## 30. QA Matrices & Acceptance (Per Feature)

### 30.1 Life Swipe
- **Functional:** correct sum validation; events not repeating within run.  
- **Edge:** offline submit queues; out‑of‑order retries idempotent.  
- **Perf:** 60fps during drag; GC pauses <10ms.

### 30.2 Quiz MP
- **Functional:** host migration if host leaves pre‑start; late join locked out.  
- **Sync:** answer window ±150ms tolerance.  
- **Abuse:** rapid‑fire submits throttled with exponential backoff.

### 30.3 Learn
- **Functional:** partial progress saved; resume state.  
- **Offline:** lesson plays from cache; reward queued.

---

## 31. Release, Rollback & Kill Switches
- Remote Config flags wrap each major feature.  
- Canary: 5% cohort for new builds.  
- Rollback: fast follow build + flags off.  
- Kill switch endpoints disable MP quiz/leaderboards instantly.

---

## 32. Observability Schemas & SLOs
- **Logs (Functions):** `reqId, uid, route, latency_ms, status, app_ver, device`.
- **Metrics:** function latency, error rate; RTDB connected clients; Firestore read/write per user.  
- **SLOs:** 99% success on callable Functions per 5‑min window; P95 latency <1.5s.

---

## 33. Backlog Blueprint (Epics → Stories)
- **E1 Auth & Bootstrap** → onboarding, starter pack, cache warm.  
- **E2 Life Swipe** → core loop, events, summary, validation.  
- **E3 Learn** → player, micro‑quiz, rewards.  
- **E4 Gamification** → XP/coins/badges, streaks.  
- **E5 Quiz MP** → rooms, rounds, finalize, snapshots.  
- **E6 Leaderboards** → live + snapshot.  
- **E7 Shop** → catalog, purchase, inventory.  
- **E8 Market Explorer** → sim + charts.  
- **E9 Growth** → push, referrals, deep links.  
- **E10 Localization & Parental**.

Each story carries acceptance criteria + instrumentation checklist.

---

## 34. Wireframe Notes & Motion Specs
- Provide Figma page IDs per screen; annotate motion tokens per component.  
- Define `Hero` pairs (home→game card, shop→item detail).  
- Particle budgets: ≤200 active; pool objects to avoid GC spikes.

---

## 35. Localization & Number Formats
- Currency symbol ₹; compact number formatting (`12.5k`).  
- Date/time: 24‑hour; locale from device; fallback `en-IN`.

---

## 36. Accessibility Test Cases
- Screen reader labels for buttons and charts; describe ROI in text.  
- High‑contrast mode toggle; test with deuteranopia filters.  
- Haptic off mode honored globally.

---

## 37. Data Diagrams (Textual)
```
users(uid) --1:M--> progress docs
users(uid) --1:M--> friends.edges(friendUid)
lessons --1:M--> quiz items
quizRooms(roomId) --1:M--> players
leaderboard(period) --M--> ranks
```
Indexes: friends(status,updatedAt), lessons(isActive), store(type), users(level).

---

## 38. API Error Codes & Client Handling
- `E/AUTH-01` invalid credentials → retry + fallback guest.  
- `E/FUNC-02` invalid payload → show toast, reopen screen.  
- `E/RATE-03` throttled → exponential backoff.  
- `E/NET-04` offline → queue mutation.

---

## 39. Feature Flags (Remote Config)
- `feature.lifeSwipe`, `feature.quizMP`, `feature.marketExplorer`, `feature.shop`, `feature.leaderboard`.  
- `economy.multiplier.xp`, `economy.multiplier.coins`.  
- `safety.push.enabled`, `safety.killSwitch.quiz`.

---

## 40. Experiment Design (A/B)
- **Hypothesis:** Higher XP multiplier in first 3 days increases D7.  
- **Split:** 50/50; guardrail metrics: crash rate, time‑in‑app.  
- **Stop:** if ARPDAU or retention drops >5%.

---

## 41. Parental Controls Expansion (Phase 4)
- **Playtime limits:** soft caps (prompts), optional hard caps (lockout).  
- **Weekly mails:** opt‑in digest with completed lessons and badges.  
- **Report abuse:** block & report on friend requests.

---

## 42. Store Presence & ASO
- Keywords: “finance for teens”, “money game”, “budget game”.  
- Screenshots: show rewards/leaderboards; localize titles.  
- Ratings prompt after 3rd successful session.

---

## 43. Dependency & Version Pinning
- Flutter SDK, Flame, Firebase packages pinned; Renovate bot PRs weekly.  
- Unity LTS if used; lock minor stream.

---

## 44. Team & RACI (example)
- **Product:** PRD, backlog, acceptance (A).  
- **Design:** Figma, animations, assets (R).  
- **Client Eng:** Flutter app (R).  
- **Backend Eng:** Functions, rules (R).  
- **QA:** test plans, automation (R).  
- **Data:** analytics, dashboards (C/R).  
- **All:** release train (I).

---

## 45. Expanded Risk Register
- **Graphics perf on low‑end devices** → dynamic quality scaler; disable particles.  
- **Function cold starts** → min instances for hot paths.  
- **RTDB costs** → throttle listeners; aggregate updates via Functions.  
- **Content drought** → pre‑plan 8‑week content calendar.

---

**End of Document**

