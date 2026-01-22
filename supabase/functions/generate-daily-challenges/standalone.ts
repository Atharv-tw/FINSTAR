/**
 * Generate Daily Challenges - STANDALONE VERSION
 * Copy this entire file to Supabase Dashboard
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeApp, cert, getApps } from "https://esm.sh/firebase-admin@11.11.0/app";
import { getFirestore } from "https://esm.sh/firebase-admin@11.11.0/firestore";
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

// ============ CHALLENGE TEMPLATES ============
const CHALLENGE_TEMPLATES = [
  { type: "playGames", title: "Play {count} games", targets: [2, 3, 5], xp: [50, 75, 100], coins: [25, 40, 60] },
  { type: "earnXp", title: "Earn {count} XP", targets: [100, 200, 500], xp: [30, 50, 80], coins: [15, 30, 50] },
  { type: "earnCoins", title: "Earn {count} coins", targets: [50, 100, 200], xp: [30, 50, 80], coins: [0, 0, 0] },
  { type: "completeLesson", title: "Complete {count} lesson(s)", targets: [1, 2, 3], xp: [60, 100, 150], coins: [30, 50, 75] },
  { type: "playLifeSwipe", title: "Play Life Swipe {count} time(s)", targets: [1, 2, 3], xp: [40, 60, 80], coins: [20, 35, 50] },
  { type: "playQuizBattle", title: "Play Quiz Battle {count} time(s)", targets: [1, 2, 3], xp: [40, 60, 80], coins: [20, 35, 50] },
  { type: "playBudgetBlitz", title: "Play Budget Blitz {count} time(s)", targets: [1, 2, 3], xp: [40, 60, 80], coins: [20, 35, 50] },
];

function getTodayIST(): string {
  const now = new Date();
  const istOffset = 5.5 * 60 * 60 * 1000;
  const istDate = new Date(now.getTime() + istOffset);
  return istDate.toISOString().split("T")[0];
}

function generateChallenges(): Array<{
  id: string;
  type: string;
  title: string;
  target: number;
  progress: number;
  xpReward: number;
  coinReward: number;
  completed: boolean;
}> {
  const shuffled = [...CHALLENGE_TEMPLATES].sort(() => Math.random() - 0.5);
  const selected = shuffled.slice(0, 3);

  return selected.map((template, index) => {
    const difficulty = Math.floor(Math.random() * 3);
    const target = template.targets[difficulty];
    const title = template.title.replace("{count}", target.toString());

    return {
      id: `challenge_${index + 1}`,
      type: template.type,
      title,
      target,
      progress: 0,
      xpReward: template.xp[difficulty],
      coinReward: template.coins[difficulty],
      completed: false,
    };
  });
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
    const { forceRegenerate = false } = body;

    const today = getTodayIST();
    const userRef = db.collection("users").doc(uid);
    const challengesRef = userRef.collection("dailyChallenges").doc(today);

    // Check if challenges already exist for today
    const existingDoc = await challengesRef.get();
    if (existingDoc.exists && !forceRegenerate) {
      return jsonResponse({
        success: true,
        alreadyGenerated: true,
        challenges: existingDoc.data()?.challenges || [],
        date: today,
      });
    }

    // Generate new challenges
    const challenges = generateChallenges();

    await challengesRef.set({
      date: today,
      challenges,
      generatedAt: new Date().toISOString(),
    });

    return jsonResponse({
      success: true,
      challenges,
      date: today,
      regenerated: forceRegenerate,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
