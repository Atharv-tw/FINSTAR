/**
 * Update Leaderboard - STANDALONE VERSION
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

// ============ MAIN HANDLER ============
serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { db, auth } = initializeFirebase();
    const body = await req.json();
    const { mode = "user", secret } = body;

    // For scheduled full update, verify secret
    if (mode === "full") {
      const cronSecret = Deno.env.get("CRON_SECRET");
      if (secret !== cronSecret) {
        return errorResponse("Unauthorized", 401);
      }

      // Full leaderboard update
      const usersSnapshot = await db.collection("users")
        .orderBy("xp", "desc")
        .limit(100)
        .get();

      const leaderboardData: Array<{
        rank: number;
        uid: string;
        displayName: string;
        xp: number;
        level: number;
        avatarUrl?: string;
      }> = [];

      let rank = 1;
      usersSnapshot.forEach((doc) => {
        const data = doc.data();
        leaderboardData.push({
          rank,
          uid: doc.id,
          displayName: data.displayName || "Anonymous",
          xp: data.xp || 0,
          level: data.level || 1,
          avatarUrl: data.avatarUrl,
        });
        rank++;
      });

      // Get current month for season ID
      const now = new Date();
      const seasonId = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

      await db.collection("leaderboards").doc(seasonId).set({
        updatedAt: new Date().toISOString(),
        entries: leaderboardData,
      });

      return jsonResponse({
        success: true,
        mode: "full",
        entriesUpdated: leaderboardData.length,
        seasonId,
      });
    }

    // User mode - update single user
    const user = await verifyAuthToken(req, auth);
    if (!user) {
      return errorResponse("Unauthorized", 401);
    }

    const uid = user.uid;
    const userDoc = await db.collection("users").doc(uid).get();

    if (!userDoc.exists) {
      return errorResponse("User not found", 404);
    }

    const userData = userDoc.data()!;
    const now = new Date();
    const seasonId = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

    // Get user's rank
    const higherXpCount = await db.collection("users")
      .where("xp", ">", userData.xp || 0)
      .count()
      .get();

    const rank = higherXpCount.data().count + 1;

    return jsonResponse({
      success: true,
      mode: "user",
      rank,
      xp: userData.xp || 0,
      level: userData.level || 1,
      seasonId,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
