/**
 * Generate Daily Challenges
 *
 * Creates 3 random daily challenges for users
 * Can be called:
 * 1. On app open (if no challenges exist for today)
 * 2. Scheduled at midnight IST
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase, warmupFirebase } from "../_shared/firebase-rest.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";
import { getTodayIST, generateDailyChallenges } from "../_shared/utils.ts";

interface GenerateChallengesRequest {
  mode?: "user" | "bulk"; // 'user' for single user, 'bulk' for scheduled
  secret?: string; // For scheduled calls
  forceRegenerate?: boolean;
}

serve(async (req: Request) => {
  const startTime = Date.now();
  const log = (msg: string) => console.log(`[${Date.now() - startTime}ms] ${msg}`);

  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Start warming up Firebase token in background (don't await yet)
    const warmupPromise = warmupFirebase();
    log("Started Firebase warmup");

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

    // For user mode, verify authentication in parallel with warmup
    log("Verifying auth...");
    const [user] = await Promise.all([
      verifyAuthTokenLight(req),
      warmupPromise, // Wait for warmup to complete
    ]);
    log("Auth verified, Firebase warmed up");

    if (!user) {
      return errorResponse("Unauthorized: Invalid or missing authentication token", 401);
    }

    const uid = user.uid;

    // Initialize Firebase for database operations (token should be cached now)
    const { db } = initializeFirebase();

    // Check if challenges already exist for today
    log("Checking existing challenges...");
    const challengesRef = db
      .collection("users")
      .doc(uid)
      .collection("dailyChallenges")
      .doc(today);

    const existingChallenges = await challengesRef.get();
    log("Firestore read complete");

    if (existingChallenges.exists && !body.forceRegenerate) {
      const data = existingChallenges.data()!;
      log("Returning existing challenges");
      return jsonResponse({
        success: true,
        alreadyGenerated: true,
        date: today,
        challenges: data.challenges,
      });
    }

    // Generate new challenges
    log("Generating new challenges...");
    const challenges = generateDailyChallenges();

    // Save to Firestore
    log("Saving to Firestore...");
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
    log("Firestore write complete");

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
