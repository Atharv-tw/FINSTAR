/**
 * Search Users - STANDALONE VERSION
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

    const user = await verifyAuthToken(req, auth);
    if (!user) {
      return errorResponse("Unauthorized", 401);
    }

    const body = await req.json();
    const { query, limit = 20 } = body;

    if (!query || query.length < 2) {
      return errorResponse("Search query must be at least 2 characters");
    }

    const currentUserId = user.uid;
    const searchQuery = query.toLowerCase().trim();

    // Search users by displayNameLower (prefix match)
    const usersSnapshot = await db.collection("users")
      .where("displayNameLower", ">=", searchQuery)
      .where("displayNameLower", "<=", searchQuery + "\uf8ff")
      .limit(Math.min(limit, 50))
      .get();

    // Get current user's friends
    const friendsSnapshot = await db.collection("users")
      .doc(currentUserId)
      .collection("friends")
      .get();

    const friendIds = new Set<string>();
    friendsSnapshot.forEach((doc) => friendIds.add(doc.id));

    // Get pending friend requests
    const sentRequestsSnapshot = await db.collection("users")
      .doc(currentUserId)
      .collection("sentFriendRequests")
      .get();

    const pendingIds = new Set<string>();
    sentRequestsSnapshot.forEach((doc) => pendingIds.add(doc.id));

    // Build results
    const users: Array<{
      uid: string;
      displayName: string;
      avatarUrl?: string;
      level: number;
      isFriend: boolean;
      isPending: boolean;
    }> = [];

    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      if (doc.id !== currentUserId) {
        users.push({
          uid: doc.id,
          displayName: userData.displayName || "Unknown",
          avatarUrl: userData.avatarUrl,
          level: userData.level || 1,
          isFriend: friendIds.has(doc.id),
          isPending: pendingIds.has(doc.id),
        });
      }
    });

    return jsonResponse({
      success: true,
      users,
      count: users.length,
    });
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
