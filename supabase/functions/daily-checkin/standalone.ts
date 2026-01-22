/**
 * Daily Check-in - STANDALONE VERSION
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

// ============ UTILS ============
const STREAK_BONUSES: Record<number, { xp: number; coins: number }> = {
  3: { xp: 50, coins: 20 },
  7: { xp: 100, coins: 50 },
  14: { xp: 200, coins: 100 },
  30: { xp: 500, coins: 200 },
};

function getTodayIST(): string {
  const now = new Date();
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istDate = new Date(now.getTime() + istOffset);
  return istDate.toISOString().split("T")[0];
}

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
    const today = getTodayIST();

    const userRef = db.collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return errorResponse("User not found", 404);
    }

    const userData = userDoc.data()!;
    const lastCheckIn = userData.lastCheckIn || "";
    const currentStreak = userData.streakDays || 0;

    if (lastCheckIn === today) {
      return jsonResponse({
        success: true,
        alreadyCheckedIn: true,
        streakDays: currentStreak,
        message: "Already checked in today",
      });
    }

    // Calculate new streak
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split("T")[0];

    let newStreak = 1;
    if (lastCheckIn === yesterdayStr) {
      newStreak = currentStreak + 1;
    }

    // Base rewards
    let xpEarned = 25;
    let coinsEarned = 10;

    // Check for milestone bonus
    let milestone: number | null = null;
    let milestoneBonus: { xp: number; coins: number } | null = null;

    for (const [days, bonus] of Object.entries(STREAK_BONUSES)) {
      if (newStreak === parseInt(days)) {
        milestone = parseInt(days);
        milestoneBonus = bonus;
        xpEarned += bonus.xp;
        coinsEarned += bonus.coins;
        break;
      }
    }

    await userRef.update({
      lastCheckIn: today,
      streakDays: newStreak,
      longestStreak: Math.max(userData.longestStreak || 0, newStreak),
      xp: FieldValue.increment(xpEarned),
      coins: FieldValue.increment(coinsEarned),
      lastActive: new Date().toISOString(),
    });

    return jsonResponse({
      success: true,
      streakDays: newStreak,
      xpEarned,
      coinsEarned,
      milestone,
      milestoneBonus,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
