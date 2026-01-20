/**
 * Reset Broken Streaks
 *
 * Scheduled task that runs daily to reset streaks
 * for users who haven't been active in 2+ days
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase } from "../_shared/firebase.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { getYesterdayIST } from "../_shared/utils.ts";

interface ResetStreaksRequest {
  secret?: string; // For scheduled calls
  dryRun?: boolean; // Test mode
}

serve(async (req: Request) => {
  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Initialize Firebase
    const { db } = initializeFirebase();

    // Parse request body
    let body: ResetStreaksRequest = {};
    try {
      body = await req.json();
    } catch {
      // No body is fine
    }

    // Verify cron secret
    const expectedSecret = Deno.env.get("CRON_SECRET");
    if (expectedSecret && body.secret !== expectedSecret) {
      return errorResponse("Unauthorized: Invalid cron secret", 401);
    }

    const yesterday = getYesterdayIST();
    const dryRun = body.dryRun || false;

    console.log(`Starting streak reset check for users inactive before ${yesterday}...`);

    // Find users who:
    // 1. Haven't been active since yesterday
    // 2. Have a streak > 0
    const usersSnapshot = await db
      .collection("users")
      .where("lastActiveDate", "<", yesterday)
      .where("streakDays", ">", 0)
      .get();

    const usersToReset = usersSnapshot.docs.map((doc) => ({
      uid: doc.id,
      lastActiveDate: doc.data().lastActiveDate,
      currentStreak: doc.data().streakDays,
    }));

    console.log(`Found ${usersToReset.length} users with broken streaks`);

    if (dryRun) {
      return jsonResponse({
        success: true,
        dryRun: true,
        usersToReset: usersToReset.length,
        users: usersToReset.slice(0, 10), // Show first 10 for debugging
      });
    }

    // Reset streaks in batches of 500 (Firestore limit)
    const batchSize = 500;
    let resetCount = 0;

    for (let i = 0; i < usersSnapshot.docs.length; i += batchSize) {
      const batch = db.batch();
      const batchDocs = usersSnapshot.docs.slice(i, i + batchSize);

      batchDocs.forEach((doc) => {
        batch.update(doc.ref, {
          streakDays: 0,
          streakResetAt: new Date().toISOString(),
          previousStreak: doc.data().streakDays, // Keep for reference
        });
        resetCount++;
      });

      await batch.commit();
      console.log(`Reset batch ${Math.floor(i / batchSize) + 1}: ${batchDocs.length} users`);
    }

    console.log(`Streak reset complete: ${resetCount} users reset`);

    return jsonResponse({
      success: true,
      dryRun: false,
      usersReset: resetCount,
      resetDate: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Error in reset-streaks:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
