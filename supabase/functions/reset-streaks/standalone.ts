/**
 * Reset Streaks (Scheduled) - STANDALONE VERSION
 * Copy this entire file to Supabase Dashboard
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeApp, cert, getApps } from "https://esm.sh/firebase-admin@11.11.0/app";
import { getFirestore } from "https://esm.sh/firebase-admin@11.11.0/firestore";

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
  };
}

// ============ MAIN HANDLER ============
serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Verify cron secret
    const body = await req.json();
    const { secret } = body;
    const cronSecret = Deno.env.get("CRON_SECRET");

    if (secret !== cronSecret) {
      return errorResponse("Unauthorized", 401);
    }

    const { db } = initializeFirebase();

    // Get yesterday's date in IST
    const now = new Date();
    const istOffset = 5.5 * 60 * 60 * 1000;
    const yesterday = new Date(now.getTime() + istOffset - 24 * 60 * 60 * 1000);
    const yesterdayStr = yesterday.toISOString().split("T")[0];

    // Find users who didn't check in yesterday and have active streaks
    const usersSnapshot = await db.collection("users")
      .where("streakDays", ">", 0)
      .get();

    let resetCount = 0;
    const batch = db.batch();

    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      const lastCheckIn = data.lastCheckIn || "";

      // If last check-in was before yesterday, reset streak
      if (lastCheckIn < yesterdayStr) {
        batch.update(doc.ref, {
          streakDays: 0,
          streakResetAt: new Date().toISOString(),
        });
        resetCount++;
      }
    });

    if (resetCount > 0) {
      await batch.commit();
    }

    return jsonResponse({
      success: true,
      resetCount,
      checkedUsers: usersSnapshot.size,
      resetDate: yesterdayStr,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
