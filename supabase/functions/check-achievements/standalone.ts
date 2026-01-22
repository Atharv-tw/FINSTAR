/**
 * Check Achievements - STANDALONE VERSION
 * Copy this entire file to Supabase Dashboard
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeApp, cert, getApps } from "https://esm.sh/firebase-admin@11.11.0/app";
import { getFirestore, FieldValue } from "https://esm.sh/firebase-admin@11.11.0/firestore";
import { getAuth } from "https://esm.sh/firebase-admin@11.11.0/auth";

// ============ CORS HELPERS ============
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function handleCors(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  return null;
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ success: false, error: message }, status);
}

// ============ FIREBASE INIT ============
function initializeFirebase() {
  if (getApps().length === 0) {
    const privateKeyBase64 = Deno.env.get("FIREBASE_PRIVATE_KEY") || "";
    const privateKey = new TextDecoder().decode(
      Uint8Array.from(atob(privateKeyBase64), (c) => c.charCodeAt(0))
    );

    initializeApp({
      credential: cert({
        projectId: Deno.env.get("FIREBASE_PROJECT_ID"),
        clientEmail: Deno.env.get("FIREBASE_CLIENT_EMAIL"),
        privateKey: privateKey,
      }),
      databaseURL: `https://${Deno.env.get("FIREBASE_PROJECT_ID")}-default-rtdb.asia-southeast1.firebasedatabase.app`,
    });
  }

  return {
    db: getFirestore(),
    auth: getAuth(),
  };
}

async function verifyAuthToken(req: Request, auth: ReturnType<typeof getAuth>) {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) return null;

  try {
    const token = authHeader.replace("Bearer ", "");
    return await auth.verifyIdToken(token);
  } catch {
    return null;
  }
}

// ============ ACHIEVEMENTS ============
const ACHIEVEMENTS = [
  { id: "first_game", name: "First Steps", check: (u: any) => u.totalGamesPlayed >= 1, xp: 100, coins: 50 },
  { id: "games_10", name: "Getting Started", check: (u: any) => u.totalGamesPlayed >= 10, xp: 500, coins: 200 },
  { id: "games_50", name: "Dedicated Player", check: (u: any) => u.totalGamesPlayed >= 50, xp: 1000, coins: 500 },
  { id: "games_100", name: "Game Master", check: (u: any) => u.totalGamesPlayed >= 100, xp: 2000, coins: 1000 },
  { id: "streak_3", name: "On a Roll", check: (u: any) => u.streakDays >= 3, xp: 200, coins: 100 },
  { id: "streak_7", name: "Week Warrior", check: (u: any) => u.streakDays >= 7, xp: 500, coins: 250 },
  { id: "streak_30", name: "Monthly Master", check: (u: any) => u.streakDays >= 30, xp: 2000, coins: 1000 },
  { id: "level_5", name: "Rising Star", check: (u: any) => u.level >= 5, xp: 300, coins: 150 },
  { id: "level_10", name: "Expert", check: (u: any) => u.level >= 10, xp: 1000, coins: 500 },
  { id: "level_20", name: "Finance Guru", check: (u: any) => u.level >= 20, xp: 3000, coins: 1500 },
  { id: "coins_1000", name: "Saver", check: (u: any) => u.coins >= 1000, xp: 200, coins: 0 },
  { id: "coins_10000", name: "Wealthy", check: (u: any) => u.coins >= 10000, xp: 1000, coins: 0 },
  { id: "xp_5000", name: "Learner", check: (u: any) => u.xp >= 5000, xp: 0, coins: 200 },
  { id: "xp_25000", name: "Scholar", check: (u: any) => u.xp >= 25000, xp: 0, coins: 1000 },
];

// ============ MAIN HANDLER ============
serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { db, auth } = initializeFirebase();

    const user = await verifyAuthToken(req, auth);
    if (!user) {
      return errorResponse("Unauthorized", 401);
    }

    const uid = user.uid;
    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return errorResponse("User not found", 404);
    }

    const userData = userDoc.data()!;

    // Get already unlocked achievements
    const achievementsSnapshot = await userRef.collection("achievements").get();
    const unlockedIds = new Set<string>();
    achievementsSnapshot.forEach((doc) => unlockedIds.add(doc.id));

    // Check for new achievements
    const newlyUnlocked: Array<{ id: string; name: string; xpReward: number; coinReward: number }> = [];
    let totalXpReward = 0;
    let totalCoinReward = 0;

    for (const achievement of ACHIEVEMENTS) {
      if (!unlockedIds.has(achievement.id) && achievement.check(userData)) {
        newlyUnlocked.push({
          id: achievement.id,
          name: achievement.name,
          xpReward: achievement.xp,
          coinReward: achievement.coins,
        });
        totalXpReward += achievement.xp;
        totalCoinReward += achievement.coins;

        // Save achievement
        await userRef.collection("achievements").doc(achievement.id).set({
          name: achievement.name,
          unlockedAt: new Date().toISOString(),
          xpReward: achievement.xp,
          coinReward: achievement.coins,
        });
      }
    }

    // Award rewards
    if (totalXpReward > 0 || totalCoinReward > 0) {
      await userRef.update({
        xp: FieldValue.increment(totalXpReward),
        coins: FieldValue.increment(totalCoinReward),
      });
    }

    return jsonResponse({
      success: true,
      newlyUnlocked,
      totalXpReward,
      totalCoinReward,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
