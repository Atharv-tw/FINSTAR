/**
 * Generate Daily Challenges
 *
 * Creates 3 random daily challenges for users
 * Can be called:
 * 1. On app open (if no challenges exist for today)
 * 2. Scheduled at midnight IST
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, FieldValue } from "../_shared/firebase.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthToken } from "../_shared/cors.ts";
import { getTodayIST, generateDailyChallenges } from "../_shared/utils.ts";

interface GenerateChallengesRequest {
  mode?: "user" | "bulk"; // 'user' for single user, 'bulk' for scheduled
  secret?: string; // For scheduled calls
  forceRegenerate?: boolean;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Initialize Firebase
    const { db, auth } = initializeFirebase();

    // Parse request body
    let body: GenerateChallengesRequest = { mode: "user" };
    try {
      body = await req.json();
    } catch {
      // Default to user mode
    }

    const mode = body.mode || "user";
    const today = getTodayIST();

    // For bulk mode (scheduled), verify secret
    if (mode === "bulk") {
      const expectedSecret = Deno.env.get("CRON_SECRET");
      if (expectedSecret && body.secret !== expectedSecret) {
        return errorResponse("Unauthorized: Invalid cron secret", 401);
      }

      // This would be used for pre-generating challenges
      // For simplicity, we generate on-demand per user
      return jsonResponse({
        success: true,
        message: "Bulk mode - challenges generated on demand per user",
      });
    }

    // For user mode, verify authentication
    const user = await verifyAuthToken(req, auth);
    if (!user) {
      return errorResponse("Unauthorized: Invalid or missing authentication token", 401);
    }

    const uid = user.uid;

    // Check if challenges already exist for today
    const challengesRef = db
      .collection("users")
      .doc(uid)
      .collection("dailyChallenges")
      .doc(today);

    const existingChallenges = await challengesRef.get();

    if (existingChallenges.exists && !body.forceRegenerate) {
      const data = existingChallenges.data()!;
      return jsonResponse({
        success: true,
        alreadyGenerated: true,
        date: today,
        challenges: data.challenges,
      });
    }

    // Generate new challenges
    const challenges = generateDailyChallenges();

    // Save to Firestore
    await challengesRef.set({
      date: today,
      challenges: challenges.map((c) => ({
        ...c,
        progress: 0,
        completed: false,
        claimed: false,
      })),
      generatedAt: new Date().toISOString(),
      allCompleted: false,
      allClaimed: false,
    });

    console.log(`Daily challenges generated for ${uid}: ${challenges.length} challenges`);

    return jsonResponse({
      success: true,
      alreadyGenerated: false,
      date: today,
      challenges: challenges.map((c) => ({
        ...c,
        progress: 0,
        completed: false,
        claimed: false,
      })),
    });
  } catch (error) {
    console.error("Error in generate-daily-challenges:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
