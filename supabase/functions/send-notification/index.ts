/**
 * Send Push Notification Function
 *
 * Sends FCM push notifications using Firebase Admin SDK (V1 API)
 * Can be called:
 * 1. By authenticated users to send to specific users
 * 2. By scheduled tasks (with CRON_SECRET) to send bulk notifications
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeFirebase } from "../_shared/firebase.ts";
import { handleCors, jsonResponse, errorResponse, verifyAuthToken } from "../_shared/cors.ts";

interface NotificationRequest {
  // For single user notification
  targetUserId?: string;

  // For bulk notification (scheduled tasks)
  mode?: "single" | "streak_reminder" | "challenge_reminder";
  secret?: string;

  // Notification content
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { db, auth, messaging } = initializeFirebase();
    const body: NotificationRequest = await req.json();
    const { mode = "single", secret, targetUserId, title, body: notificationBody, data, imageUrl } = body;

    // For bulk modes, verify cron secret
    if (mode !== "single") {
      const expectedSecret = Deno.env.get("CRON_SECRET");
      if (expectedSecret && secret !== expectedSecret) {
        return errorResponse("Unauthorized: Invalid cron secret", 401);
      }
    } else {
      // For single mode, verify user authentication
      const authResult = await verifyAuthToken(req, auth);
      if (!authResult) {
        return errorResponse("Unauthorized", 401);
      }
    }

    // Handle different modes
    if (mode === "streak_reminder") {
      return await sendStreakReminders(db, messaging);
    } else if (mode === "challenge_reminder") {
      return await sendChallengeReminders(db, messaging);
    }

    // Single user notification
    if (!targetUserId || !title || !notificationBody) {
      return errorResponse("Missing required fields: targetUserId, title, body");
    }

    const result = await sendToUser(db, messaging, targetUserId, {
      title,
      body: notificationBody,
      data,
      imageUrl,
    });

    return jsonResponse(result);
  } catch (error) {
    console.error("Error sending notification:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});

/**
 * Send notification to a single user
 */
async function sendToUser(
  db: FirebaseFirestore.Firestore,
  messaging: any,
  userId: string,
  notification: { title: string; body: string; data?: Record<string, string>; imageUrl?: string }
): Promise<{ success: boolean; sent: number; failed: number; error?: string }> {
  // Get user's FCM tokens
  const tokensSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("fcmTokens")
    .get();

  if (tokensSnapshot.empty) {
    return { success: false, sent: 0, failed: 0, error: "User has no registered devices" };
  }

  const tokens: string[] = [];
  tokensSnapshot.forEach((doc) => {
    const token = doc.data().token || doc.id;
    if (token) tokens.push(token);
  });

  if (tokens.length === 0) {
    return { success: false, sent: 0, failed: 0, error: "No valid FCM tokens found" };
  }

  // Send to all tokens
  const message = {
    notification: {
      title: notification.title,
      body: notification.body,
      ...(notification.imageUrl && { imageUrl: notification.imageUrl }),
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      ...notification.data,
    },
    tokens,
  };

  try {
    const response = await messaging.sendEachForMulticast(message);

    // Clean up invalid tokens
    if (response.failureCount > 0) {
      const tokensToRemove: string[] = [];
      response.responses.forEach((resp: any, idx: number) => {
        if (!resp.success && resp.error?.code === "messaging/registration-token-not-registered") {
          tokensToRemove.push(tokens[idx]);
        }
      });

      // Remove invalid tokens
      for (const token of tokensToRemove) {
        await db.collection("users").doc(userId).collection("fcmTokens").doc(token).delete();
      }
    }

    console.log(`Notification sent to ${userId}: ${response.successCount} success, ${response.failureCount} failed`);

    return {
      success: response.successCount > 0,
      sent: response.successCount,
      failed: response.failureCount,
    };
  } catch (error) {
    console.error(`Failed to send notification to ${userId}:`, error);
    return { success: false, sent: 0, failed: tokens.length, error: error.message };
  }
}

/**
 * Send streak reminder notifications to users who haven't checked in today
 */
async function sendStreakReminders(
  db: FirebaseFirestore.Firestore,
  messaging: any
): Promise<Response> {
  const today = new Date();
  const todayStr = today.toISOString().split("T")[0];

  // Find users with active streaks who haven't checked in today
  const usersSnapshot = await db
    .collection("users")
    .where("streakDays", ">", 0)
    .where("lastActiveDate", "<", todayStr)
    .limit(500) // Process in batches
    .get();

  let sent = 0;
  let failed = 0;

  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data();
    const streakDays = userData.streakDays || 0;

    const result = await sendToUser(db, messaging, userDoc.id, {
      title: "Don't lose your streak! 🔥",
      body: `You have a ${streakDays}-day streak. Open FINSTAR to keep it going!`,
      data: { type: "streak_reminder", streakDays: String(streakDays) },
    });

    if (result.success) sent++;
    else failed++;
  }

  console.log(`Streak reminders: ${sent} sent, ${failed} failed out of ${usersSnapshot.size} users`);

  return jsonResponse({
    success: true,
    mode: "streak_reminder",
    usersProcessed: usersSnapshot.size,
    sent,
    failed,
  });
}

/**
 * Send challenge reminder notifications to users with incomplete challenges
 */
async function sendChallengeReminders(
  db: FirebaseFirestore.Firestore,
  messaging: any
): Promise<Response> {
  const today = new Date();
  const todayStr = today.toISOString().split("T")[0];

  // Get users who were active today (have daily challenges)
  const usersSnapshot = await db
    .collection("users")
    .where("lastActiveDate", "==", todayStr)
    .limit(500)
    .get();

  let sent = 0;
  let failed = 0;

  for (const userDoc of usersSnapshot.docs) {
    // Check their daily challenges
    const challengesDoc = await db
      .collection("users")
      .doc(userDoc.id)
      .collection("dailyChallenges")
      .doc(todayStr)
      .get();

    if (!challengesDoc.exists) continue;

    const challengesData = challengesDoc.data();
    const challenges = challengesData?.challenges || [];
    const incomplete = challenges.filter((c: any) => !c.completed).length;

    if (incomplete === 0) continue; // All completed, no reminder needed

    const result = await sendToUser(db, messaging, userDoc.id, {
      title: "Challenges waiting! 🎯",
      body: `You have ${incomplete} challenge${incomplete > 1 ? "s" : ""} left today. Complete them for bonus rewards!`,
      data: { type: "challenge_reminder", incomplete: String(incomplete) },
    });

    if (result.success) sent++;
    else failed++;
  }

  console.log(`Challenge reminders: ${sent} sent, ${failed} failed`);

  return jsonResponse({
    success: true,
    mode: "challenge_reminder",
    usersProcessed: usersSnapshot.size,
    sent,
    failed,
  });
}
