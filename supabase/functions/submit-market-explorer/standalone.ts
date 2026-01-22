/**
 * Submit Market Explorer Game Result - STANDALONE VERSION
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

function calculateMarketExplorerRewards(portfolioReturn: number, diversificationScore: number, decisionsCount: number) {
  let xp = Math.floor(Math.max(0, portfolioReturn) * 2) + Math.floor(diversificationScore * 0.3);
  let coins = Math.floor(Math.max(0, portfolioReturn) * 1.5) + Math.floor(diversificationScore * 0.2);

  xp += Math.min(decisionsCount * 2, 20);
  coins += Math.min(decisionsCount, 10);

  if (portfolioReturn >= 20) {
    xp += 30;
    coins += 25;
  }

  if (diversificationScore >= 80) {
    xp += 15;
    coins += 15;
  }

  return { xp, coins };
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
    const { portfolioValue, initialValue, portfolio, decisionsCount = 0 } = body;

    if (portfolioValue === undefined || initialValue === undefined || !portfolio) {
      return errorResponse("Missing required fields: portfolioValue, initialValue, portfolio");
    }

    const portfolioReturn = ((portfolioValue - initialValue) / initialValue) * 100;

    // Calculate diversification score
    const values = Object.values(portfolio) as number[];
    const total = values.reduce((sum, val) => sum + val, 0);
    const assetCount = values.filter(v => v > 0).length;
    const diversificationScore = Math.min(100, assetCount * 20 + (total > 0 ? 20 : 0));

    const rewards = calculateMarketExplorerRewards(portfolioReturn, diversificationScore, decisionsCount);
    const xpEarned = rewards.xp;
    const coinsEarned = rewards.coins;

    const userRef = db.collection("users").doc(uid);
    const progressRef = userRef.collection("progress").doc("market_explorer");

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
          bestReturn: Math.max(currentData?.bestReturn || -100, portfolioReturn),
          lastReturn: portfolioReturn,
          totalDecisions: FieldValue.increment(decisionsCount),
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
      portfolioReturn,
      diversificationScore,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
