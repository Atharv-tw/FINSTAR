// Search Users Function
// Searches users by display name for friend adding

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { initializeFirebase } from "../_shared/firebase.ts";
import { corsHeaders, handleCors, jsonResponse, errorResponse, verifyAuthToken } from "../_shared/cors.ts";

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { db, auth } = initializeFirebase();

    // Get request body
    const { query, limit = 20 } = await req.json();

    // Verify authentication
    const authResult = await verifyAuthToken(req, auth);
    if (!authResult) {
      return errorResponse("Unauthorized", 401);
    }

    // Validate query
    if (!query || query.length < 2) {
      return errorResponse("Search query must be at least 2 characters");
    }

    const currentUserId = authResult.uid;
    const searchQuery = query.toLowerCase().trim();

    // Search users by displayName (prefix match)
    // Firestore doesn't support full-text search, so we use prefix matching
    const usersSnapshot = await db
      .collection('users')
      .where('displayNameLower', '>=', searchQuery)
      .where('displayNameLower', '<=', searchQuery + '\uf8ff')
      .limit(Math.min(limit, 50))
      .get();

    // Get current user's friends to filter out
    const friendsSnapshot = await db
      .collection('users')
      .doc(currentUserId)
      .collection('friends')
      .get();

    const friendIds = new Set<string>();
    friendsSnapshot.forEach((doc) => {
      friendIds.add(doc.id);
    });

    // Get pending friend requests
    const sentRequestsSnapshot = await db
      .collection('users')
      .doc(currentUserId)
      .collection('sentFriendRequests')
      .get();

    const pendingIds = new Set<string>();
    sentRequestsSnapshot.forEach((doc) => {
      pendingIds.add(doc.id);
    });

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
      // Exclude current user
      if (doc.id !== currentUserId) {
        users.push({
          uid: doc.id,
          displayName: userData.displayName || 'Unknown',
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
    console.error("Error searching users:", error);
    return errorResponse(error.message, 500);
  }
});
