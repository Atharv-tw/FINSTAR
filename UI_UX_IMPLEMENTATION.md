# FINSTAR Design Bible (Nixtio-Inspired Finance Education App)

## System Role
You are a Principal Product Designer + Lead Frontend Architect tasked with designing and specifying a complete Nixtio-inspired **Finance Education App for Teens** called **FINSTAR**.  
You must generate the **entire design specification** — visual, structural, motion, behavioral, and technical — at production depth so that both **Figma designers and Flutter/React Native developers** can immediately build from it.

Your answers must be exhaustive, structured, and written like a **studio design bible** — combining UX reasoning, visual design system rules, animation curves, component hierarchy, asset inventory, developer hints, and accessibility standards.

---

## 🎯 Purpose
Create a **gamified finance learning app** that teaches budgeting, saving, investing, and personal finance concepts through games and micro-interactions.

## 📱 App Identity
**Name:** FINSTAR  
**Tagline:** “Learn Money. Play Smart.”

## 👥 Target Audience
- Teens aged 14 – 19  
- Learning style: visual, interactive, short attention windows  
- Preferred aesthetic: toy-like, soft-3D, friendly fintech  

## 🧠 Design Intent
**Core emotional arc:** Trust → Curiosity → Challenge → Reward  
**Visual mood:** Nixtio-style — playful geometric depth, rich gradients, 3D-like mascot, physical lighting.

---

## 🌈 Visual Architecture
| Attribute | Value |
|------------|--------|
| Primary Gradient | #2E5BFF → #00D4FF |
| Secondary Gradient | #A9FF68 → #4AE56B |
| Accent (Rewards) | #FFD45D → #FF914D |
| Background | #0B0B0D → #15151A with faint geometric overlays |
| Typography | Poppins (Title), Inter (Body), Space Mono (Numerics) |
| Corner Radius System | 8 / 12 / 24 / 40 px tiers |
| Shadow Depths | Elevation 1 – 6 with hue-tinted glows |
| Grid | 8 pt baseline, safe area 24 px, max content width = device − 48 px |
| Icon Style | Filled geometric SVG, subtle gradient fills |

---

## 🧩 Design Tokens
Claude must output a JSON dictionary defining colors, spacing, typography, motion durations, curves, shadows, radii, elevations, and gradients consistent with Nixtio standards.

---

## 🦸 Home Screen — “Stacked Cards Hero Interface”
Cinematic layout featuring a **3D mascot (Piggy or Bunny)** at the top and **interactive stacked collectible cards** at the bottom.

### Layout Logic
- **Top Bar:** XP ring + coins pill (sticky)
- **Hero Section:** 55% height, floating mascot, parallax lighting
- **Card Stack Zone:** bottom 45%, 4–5 tall cards (Play Games, Learn, Rewards, Friends)
- **Collapsed:** top 60 px visible
- **Expanded:** 70% screen height
- **Overlap:** 16 px offset, progressive blur
- **Scroll reveals cards, shrinks hero**
- **Bottom Dock:** glassmorphic nav bar + FAB (Life Swipe, Quiz Battle, Market Explorer)

### Motion Phases
| Motion | Values |
|---------|---------|
| Hero scale | 1.0 → 0.4, blur 0 → 10 px, easeOutQuart |
| Stack lift | −60 px, easeOutQuad |
| Card expand | spring(300, 30, 0.5, 0) |
| XP bar pin | slideUp 300 ms |
| Background hue drift | ±8° / 30 s loop |

### Interactions
- Tap = glow pulse + 1.05× scale → 1.0  
- Scroll threshold = haptic tick  
- Level-Up = Confetti Lottie + victory sound  
- Idle = floating breathing loop (+/− 2%)

---

## 🎮 Game Screens
### 1️⃣ Life Swipe (Budgeting Game)
- 2×2 jars: Needs, Wants, Savings, Invest  
- Drag/drop bundles into jars (spring physics)  
- Random events appear (“Phone repair ₹2500”)  
- Wrong drop = shake animation  
- Summary = stack bar chart + XP tween + coin sparkle  

### 2️⃣ Market Explorer (Investment Game)
- 3D toy islands (FD, SIP, Stocks, Crypto)  
- Simulate “5 years” → animate ROI in 2 s line chart  
- ROI above goal → coin rain; below goal → hint card  

### 3️⃣ Quiz Battle
- Question card + 4 answers  
- Timer ring (green→red)  
- Multiplayer avatar bounce, power-up ripple  

---

## 📚 Learn Modules
- Carousel of bite-sized animated lessons  
- Micro-quiz at end of each lesson  
- Reward: coin fly + XP increment + badge sparkle  

---

## 🏆 Rewards & Shop
- Grid of badges (2×3), gold border for rare  
- Cosmetic-only store (avatars, backgrounds)  
- Purchase animation: coin fly header → item  
- Lottie < 1 MB, PNG < 200 KB  

---

## 🧭 Friends & Leaderboard
- Tabs: Daily / Weekly / All-time  
- Top 3 avatars pulse  
- Share score → screenshot overlay (with watermark)

---

## ⚙️ Gamification Engine
- XP = (level² × 100)  
- Coins = Firestore record  
- Badges = {title, desc, xp, icon, earnedAt}  
- Daily streaks = timestamp delta  
- Each event → Lottie + sound + haptic combo  

---

## 🧱 Component Library
`GradientCard`, `BlurDock`, `XpRing`, `CoinPill`, `JarWidget`, `IslandCard`, `QuizTile`, `PowerChip`, `BadgeCell`, `ModalSheet`, `ProgressBar`, `ChartLine`  
Each component must specify states, props, animations, shadows, hit-area sizes.

---

## ⚙️ Tech Architecture
| Layer | Tool |
|--------|------|
| Frontend | Flutter (≥3.24) or React Native (Expo ≥51) |
| Backend | Firebase Auth, Firestore, Cloud Storage, Functions |
| Realtime | Firebase Realtime DB (Quiz multiplayer) |
| Analytics | Firebase Analytics + BigQuery |
| Monitoring | Crashlytics + Performance |
| Animation | rive_flutter / lottie |
| Shader | BackdropFilter-based hero blur |

---

## 🔉 Audio & Haptics
| Event | Sound | Haptic |
|--------|--------|--------|
| Tap | tap_soft.wav | Light |
| Coin Gain | coin_roll.wav | Medium |
| Victory | victory_short.wav | Strong |
| Error | error_thud.wav | Medium |

Volume 0.3–0.6 normalized.

---

## ♿ Accessibility
- Tap targets ≥48 px  
- WCAG AA contrast  
- Dyslexia font (OpenDyslexic)  
- Color-blind safe palette  
- Reduce Motion → −40% duration  
- VoiceOver labels for all icons  

---

## 📦 Asset Delivery
| Type | Format | Notes |
|-------|---------|-------|
| Mascot | GLB + 3 Lottie loops (idle, celebrate, sad) |
| Backgrounds | SVG gradient fields (3 themes) |
| Icons | SVG sprite sheet (24 / 32 px) |
| Audio | WAV → OGG ≤200 KB |
| Animations | Lottie JSON <1 MB |

---

## 🧰 Developer Hints
Claude must output widget stubs (Flutter):
```dart
class GradientCard extends StatelessWidget {}
class BlurDock extends StatelessWidget {}
class XpRing extends StatelessWidget {}
class CoinIncrementAnimator extends StatefulWidget {}
```

Each with animation controllers, curves, and shader references.

---

## 📊 Analytics Events
`card_open`, `lesson_complete`, `quiz_win`, `level_up`, `purchase`, `share_score`, `streak_maintained`  
Params: {uid, screen, xp, coins, timestamp}

---

## 🧪 Performance Budgets
| Metric | Target |
|---------|---------|
| FPS | ≥ 60 |
| First Paint | < 1s |
| Tap Latency | < 100ms |
| Memory | < 150MB |
| CPU Animation | < 10% |
| Lottie File | < 1MB |
| App Bundle | < 100MB |

---

## 🧾 Output Structure (Claude)
1. Design Tokens (JSON)  
2. Screen-by-Screen Specs  
3. Component Blueprint Library  
4. Motion & Micro-Interaction Catalogue  
5. Accessibility Checklist  
6. Asset Inventory Table  
7. Audio/Haptic Mapping  
8. Developer Implementation Hints  
9. Figma Component Guide  
10. QA Acceptance Criteria  

---

## ⚠️ Non-Goals
- No skeuomorphic textures or flat gray UI  
- No heavy physics simulation  
- No pay-to-win loops  
- No redundant modals  

---

## 🧭 If Ambiguous
Claude must make logical UI/UX decisions, document under “Assumptions & Design Rationale,” and continue without clarification.

---

## 🧩 Output Style
- Use hierarchical markdown headings  
- Provide tables for attributes and metrics  
- Use fenced code for JSON / Dart / Tokens  
- Ensure all measurements, durations, and opacities are precise  
- Treat as a **production design document**

---

## ✅ Memory Purpose
This file acts as a **persistent context memory** so Claude always remembers FINSTAR’s design vision, tone, color system, layout logic, and technical expectations even if conversation context is compacted.
