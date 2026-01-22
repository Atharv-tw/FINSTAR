/**
 * Update Leaderboard
 *
 * Can be called:
 * 1. After game completion to update user's position
 * 2. Scheduled daily to refresh full leaderboard
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, warmupFirebase } from "../_shared/firebase-rest.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";
import { getCurrentSeasonId, getTodayIST } from "../_shared/utils.ts";

interface LeaderboardUpdate {
  mode?: "full" | "user"; // 'full' for scheduled refresh, 'user' for single user update
  secret?: string; // For scheduled calls without auth
}

serve(async (req: Request) => {
  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Start Firebase warmup early
    const warmupPromise = warmupFirebase();

    // Parse request body
    let body: LeaderboardUpdate = { mode: "user" };
    try {
      body = await req.json();
    } catch {
      // Default to user mode
    }

    const mode = body.mode || "user";

    // For scheduled full refresh, verify secret
    if (mode === "full") {
      const expectedSecret = Deno.env.get("CRON_SECRET");
      if (expectedSecret && body.secret !== expectedSecret) {
        // If no secret configured, allow for testing
        // In production, always require secret
        if (expectedSecret) {
          return errorResponse("Unauthorized: Invalid cron secret", 401);
        }
      }

      await warmupPromise;
      const { db, rtdb } = initializeFirebase();
      // Full leaderboard refresh
      return await refreshFullLeaderboard(db, rtdb);
    }

    // For user mode, verify authentication (in parallel with warmup)
    const [user] = await Promise.all([
      verifyAuthTokenLight(req),
      warmupPromise,
    ]);

    if (!user) {
      return errorResponse("Unauthorized: Invalid or missing authentication token", 401);
    }

    const { db, rtdb } = initializeFirebase();
    const uid = user.uid;

    // Update single user's leaderboard entry
    return await updateUserLeaderboardEntry(db, rtdb, uid);
  } catch (error) {
    console.error("Error in update-leaderboard:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});

async function refreshFullLeaderboard(
  db: FirebaseFirestore.Firestore,
  rtdb: Database
): Promise<Response> {
  console.log("Starting full leaderboard refresh...");

  const seasonId = getCurrentSeasonId();

  // Get top 100 users by XP
  const usersSnapshot = await db
    .collection("users")
    .orderBy("xp", "desc")
    .limit(100)
    .get();

  const rankings = usersSnapshot.docs.map((doc, index) => {
    const data = doc.data();
    return {
      rank: index + 1,
      uid: doc.id,
      displayName: data.displayName || "Player",
      xp: data.xp || 0,
      level: data.level || 1,
      avatarUrl: data.avatarUrl || null,
    };
  });

  // Get total user count
  const totalUsersSnapshot = await db.collection("users").count().get();
  const totalUsers = totalUsersSnapshot.data().count;

  // Save to Firestore
  await db.collection("leaderboards").doc(seasonId).set({
    seasonId,
    period: "monthly",
    rankings,
    updatedAt: new Date().toISOString(),
    totalUsers,
  });

  // Update Realtime Database for live leaderboard
  await rtdb.ref("leaderboards/live").set({
    top100: rankings,
    updatedAt: Date.now(),
    totalUsers,
  });

  console.log(`Full leaderboard updated: ${rankings.length} users, total ${totalUsers}`);

  return jsonResponse({
    success: true,
    mode: "full",
    usersRanked: rankings.length,
    totalUsers,
    seasonId,
  });
}

async function updateUserLeaderboardEntry(
  db: FirebaseFirestore.Firestore,
  rtdb: Database,
  uid: string
): Promise<Response> {
  // Get user data
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) {
    return errorResponse("User not found", 404);
  }

  const userData = userDoc.data()!;
  const userXp = userData.xp || 0;

  // Count users with more XP to get rank
  const higherRankedSnapshot = await db
    .collection("users")
    .where("xp", ">", userXp)
    .count()
    .get();

  const rank = higherRankedSnapshot.data().count + 1;

  // Update user's rank in their profile
  await db.collection("users").doc(uid).update({
    rank,
    rankUpdatedAt: new Date().toISOString(),
  });

  // Update live leaderboard entry if in top 100
  if (rank <= 100) {
    const leaderboardEntry = {
      rank,
      uid,
      displayName: userData.displayName || "Player",
      xp: userXp,
      level: userData.level || 1,
      avatarUrl: userData.avatarUrl || null,
    };

    // Update in Realtime Database
    await rtdb.ref(`leaderboards/live/entries/${uid}`).set(leaderboardEntry);
  }

  console.log(`Leaderboard updated for ${uid}: rank ${rank}`);

  return jsonResponse({
    success: true,
    mode: "user",
    uid,
    rank,
    xp: userXp,
    level: userData.level || 1,
  });
}

// Type definitions for Firebase
interface Database {
  ref: (path: string) => {
    set: (data: unknown) => Promise<void>;
  };
}
