/**
 * Submit Quiz Battle Game Result - STANDALONE VERSION
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
const BASE_XP = 1000;
const XP_MULTIPLIER = 1.5;

function calculateLevel(totalXp: number): number {
  if (totalXp < BASE_XP) return 1;
  return Math.floor(Math.log(totalXp / BASE_XP) / Math.log(XP_MULTIPLIER)) + 1;
}

function calculateQuizBattleRewards(correctAnswers: number, totalQuestions: number, timeBonus: number, isWinner: boolean) {
  const accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  let xp = correctAnswers * 10 + Math.floor(timeBonus * 0.5);
  let coins = correctAnswers * 8 + Math.floor(timeBonus * 0.3);

  if (accuracy === 1.0) {
    xp += 50;
    coins += 40;
  }

  if (isWinner) {
    xp += 30;
    coins += 25;
  }

  return { xp, coins, accuracy };
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
    const body = await req.json();
    const { correctAnswers, totalQuestions, timeBonus = 0, isWinner = false } = body;

    if (correctAnswers === undefined || totalQuestions === undefined) {
      return errorResponse("Missing required fields: correctAnswers, totalQuestions");
    }

    const rewards = calculateQuizBattleRewards(correctAnswers, totalQuestions, timeBonus, isWinner);
    const xpEarned = rewards.xp;
    const coinsEarned = rewards.coins;

    const userRef = db.collection("users").doc(uid);
    const progressRef = userRef.collection("progress").doc("quiz_battle");

    let newLevel = 1;
    let leveledUp = false;
    let newXp = 0;

    await db.runTransaction(async (transaction: FirebaseFirestore.Transaction) => {
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new Error("User not found");
      }

      const userData = userDoc.data()!;
      const currentXp = userData.xp || 0;
      const currentLevel = userData.level || 1;

      newXp = currentXp + xpEarned;
      newLevel = calculateLevel(newXp);
      leveledUp = newLevel > currentLevel;

      transaction.update(userRef, {
        xp: FieldValue.increment(xpEarned),
        coins: FieldValue.increment(coinsEarned),
        level: newLevel,
        totalGamesPlayed: FieldValue.increment(1),
        lastActive: new Date().toISOString(),
      });

      const progressDoc = await transaction.get(progressRef);
      const currentData = progressDoc.exists ? progressDoc.data() : {};

      transaction.set(
        progressRef,
        {
          lastPlayed: new Date().toISOString(),
          timesPlayed: FieldValue.increment(1),
          totalCorrect: FieldValue.increment(correctAnswers),
          totalQuestions: FieldValue.increment(totalQuestions),
          wins: isWinner ? FieldValue.increment(1) : (currentData?.wins || 0),
          bestAccuracy: Math.max(currentData?.bestAccuracy || 0, rewards.accuracy),
        },
        { merge: true }
      );
    });

    return jsonResponse({
      success: true,
      xpEarned,
      coinsEarned,
      newLevel,
      newXp,
      leveledUp,
      accuracy: rewards.accuracy,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
