# Projected Costs (Launch to 12 Months)

Date: 2026-02-08

This estimate is based on the current repository configuration and code usage. It assumes:
- Android launch only
- Firebase (Firestore primary, Realtime DB secondary)
- OneSignal Free plan
- Cloudinary Free plan
- No paid market data APIs
- No paid Firebase Extensions
- No paid hosting for web (not launching web)

Numbers below are practical projections. Actual usage can vary with feature adoption, retention, and data patterns.

---

## One-Time Launch Cost
- Google Play Developer Account: **$25 one-time**

---

## What The App Uses (from code)
Primary data store:
- **Cloud Firestore** (used throughout providers and services)

Secondary:
- **Realtime Database** (limited usage)

Notifications:
- **Firebase Cloud Messaging (FCM)**
- **OneSignal (mobile push)**

Media:
- **Cloudinary (Free plan)**

Other:
- Crash reporting: **Firebase Crashlytics**

---

## Firebase Free-Tier Limits (Spark Plan)
- Firestore: **50,000 reads/day**, **20,000 writes/day**, **1 GiB storage**, **10 GiB outbound/month**
- FCM: **no-cost**
- Crashlytics: **no-cost**

---

## Usage Scenarios (DAU 100 / 1,000 / 5,000)
Assumption per active user per day (typical for a learning/game app):
- Reads: **30**
- Writes: **5**

These assumptions are conservative and align with screens like achievements, leaderboard, challenges, and profile.

### Scenario A: 100 DAU
- Reads/day: **3,000**
- Writes/day: **500**
- Outcome: **Well within free tier**
- **Monthly cost: $0** (Firebase + OneSignal + Cloudinary Free)

### Scenario B: 1,000 DAU
- Reads/day: **30,000**
- Writes/day: **5,000**
- Outcome: **Within free tier**
- **Monthly cost: $0**

### Scenario C: 5,000 DAU
- Reads/day: **150,000**
- Writes/day: **25,000**
- Outcome: **Above Firestore free tier**
- **Monthly cost: paid Firebase (Blaze required)**

---

## Estimated Monthly Cost at 5,000 DAU (Blaze)
Using 150k reads/day and 25k writes/day:
- Reads/month: ~4.5M
- Writes/month: ~0.75M

Firebase Blaze pricing (approx):
- Firestore reads: **$0.06 per 100k**
- Firestore writes: **$0.18 per 100k**

Estimated Firestore cost:
- Reads: (4.5M / 100k) * $0.06 ˜ **$2.70**
- Writes: (0.75M / 100k) * $0.18 ˜ **$1.35**
- Subtotal (reads+writes): **~$4.05/month**

Bandwidth and storage:
- Likely small at this scale unless you store large images/videos directly in Firebase
- With Cloudinary for media, Firebase storage costs remain minimal

**Projected Firebase cost at 5,000 DAU: ~$5–$15/month**

---

## OneSignal
- Free plan includes unlimited mobile push
- **Cost: $0/month**

---

## Cloudinary
- Free plan: **$0/month** (25 credits)
- If image/video usage is low, free tier is sufficient

---

## 12-Month Cost Projection (3 Growth Tracks)

### Track 1: Slow Growth (100 DAU steady)
- Months 1–12: **$0/month**
- 12-month total: **$0**

### Track 2: Moderate Growth (1,000 DAU by Month 6)
- Months 1–6: **$0/month**
- Months 7–12: **$0/month** (still in free tier)
- 12-month total: **$0**

### Track 3: Strong Growth (5,000 DAU by Month 6)
- Months 1–5: **$0/month**
- Months 6–12: **$5–$15/month** (Firestore usage)
- 12-month total: **~$30–$90**

---

## Summary
- **Minimum yearly cost:** $0 (excluding Play Store account)
- **Likely yearly cost for 5,000 DAU:** ~$30–$90
- **One-time launch:** $25 (Google Play)

---

## Notes
- Costs jump only if read/write volume or outbound bandwidth grows sharply.
- If you move to paid OneSignal features, a monthly fee will apply.
- If you enable Firebase Cloud Functions, Blaze is required (still cheap at low volume).

---

If you want, I can re-run this with updated real usage metrics once analytics are live.
