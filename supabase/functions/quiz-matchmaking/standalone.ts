/**
 * Quiz Matchmaking - STANDALONE VERSION
 * Copy this entire file to Supabase Dashboard
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { initializeApp, cert, getApps } from "https://esm.sh/firebase-admin@11.11.0/app";
import { getFirestore } from "https://esm.sh/firebase-admin@11.11.0/firestore";
import { getDatabase } from "https://esm.sh/firebase-admin@11.11.0/database";
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
    rtdb: getDatabase(),
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

// ============ QUIZ QUESTIONS ============
function generateQuizQuestions(count: number) {
  const questionBank = [
    { question: "What is the 50/30/20 budgeting rule?", options: ["50% needs, 30% wants, 20% savings", "50% savings, 30% needs, 20% wants", "50% wants, 30% savings, 20% needs", "50% investments, 30% savings, 20% spending"], correctAnswer: 0 },
    { question: "What does SIP stand for in investing?", options: ["Standard Investment Plan", "Systematic Investment Plan", "Secure Investment Protocol", "Simple Interest Plan"], correctAnswer: 1 },
    { question: "What is compound interest?", options: ["Interest only on the principal amount", "Interest on both principal and accumulated interest", "A fixed rate of interest", "Interest that decreases over time"], correctAnswer: 1 },
    { question: "What is an emergency fund?", options: ["Money for buying luxury items", "Money saved for retirement", "Money set aside for unexpected expenses", "Money invested in stocks"], correctAnswer: 2 },
    { question: "What is diversification in investing?", options: ["Putting all money in one stock", "Spreading investments across different assets", "Investing only in real estate", "Saving money in a bank account"], correctAnswer: 1 },
    { question: "What is inflation?", options: ["Decrease in money supply", "Increase in the general price level over time", "A type of tax", "Interest earned on savings"], correctAnswer: 1 },
    { question: "What is a credit score?", options: ["Your total income", "A number representing your creditworthiness", "The amount you owe", "Your bank account balance"], correctAnswer: 1 },
    { question: "What is a mutual fund?", options: ["A personal savings account", "A pool of money from multiple investors", "A type of loan", "Government bonds only"], correctAnswer: 1 },
    { question: "What should you do before investing?", options: ["Borrow money to invest more", "Build an emergency fund first", "Invest in high-risk stocks immediately", "Ignore your debts"], correctAnswer: 1 },
    { question: "What is the recommended months of expenses for an emergency fund?", options: ["1-2 months", "3-6 months", "12 months", "No specific amount"], correctAnswer: 1 },
  ];

  const shuffled = [...questionBank].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, shuffled.length));
}

// ============ MAIN HANDLER ============
serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { db, rtdb, auth } = initializeFirebase();

    const user = await verifyAuthToken(req, auth);
    if (!user) {
      return errorResponse("Unauthorized", 401);
    }

    const body = await req.json();
    const { action, matchId, category = "general", answer, questionIndex } = body;
    const userId = user.uid;

    // Get user profile
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      return errorResponse("User not found", 404);
    }

    const userData = userDoc.data()!;
    const userProfile = {
      uid: userId,
      displayName: userData.displayName || "Player",
      avatarUrl: userData.avatarUrl,
      ready: false,
      score: 0,
      answers: [],
    };

    const matchesRef = rtdb.ref("quizMatches");

    switch (action) {
      case "find_match": {
        // Look for existing waiting match
        const waitingMatches = await matchesRef.orderByChild("status").equalTo("waiting").once("value");
        const matchData = waitingMatches.val();
        let foundMatchId: string | null = null;

        if (matchData) {
          for (const [id, match] of Object.entries(matchData) as [string, any][]) {
            if (match.category === category && match.player1.uid !== userId) {
              foundMatchId = id;
              break;
            }
          }
        }

        if (foundMatchId) {
          // Join existing match
          const matchRef = matchesRef.child(foundMatchId);
          const match = (await matchRef.once("value")).val();

          await matchRef.update({
            player2: userProfile,
            status: "matched",
            updatedAt: new Date().toISOString(),
          });

          return jsonResponse({
            success: true,
            action: "joined",
            matchId: foundMatchId,
            opponent: { uid: match.player1.uid, displayName: match.player1.displayName, avatarUrl: match.player1.avatarUrl },
          });
        }

        // Create new match
        const newMatchRef = matchesRef.push();
        const newMatchId = newMatchRef.key;
        const questions = generateQuizQuestions(10);

        await newMatchRef.set({
          matchId: newMatchId,
          player1: userProfile,
          status: "waiting",
          category,
          questions,
          currentQuestionIndex: 0,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });

        return jsonResponse({ success: true, action: "created", matchId: newMatchId });
      }

      case "ready": {
        if (!matchId) return errorResponse("Match ID required");

        const matchRef = matchesRef.child(matchId);
        const match = (await matchRef.once("value")).val();

        if (!match) return errorResponse("Match not found", 404);

        const isPlayer1 = match.player1.uid === userId;
        const playerKey = isPlayer1 ? "player1" : "player2";

        await matchRef.child(playerKey).update({ ready: true });

        const updatedMatch = (await matchRef.once("value")).val();
        if (updatedMatch.player1.ready && updatedMatch.player2?.ready) {
          await matchRef.update({ status: "in_progress", startTime: new Date().toISOString() });
          return jsonResponse({
            success: true,
            status: "starting",
            questions: updatedMatch.questions.map((q: any) => ({ question: q.question, options: q.options })),
          });
        }

        return jsonResponse({ success: true, status: "waiting_for_opponent" });
      }

      case "submit_answer": {
        if (!matchId || answer === undefined || questionIndex === undefined) {
          return errorResponse("Match ID, answer, and questionIndex required");
        }

        const matchRef = matchesRef.child(matchId);
        const match = (await matchRef.once("value")).val();

        if (!match || match.status !== "in_progress") {
          return errorResponse("Match not in progress");
        }

        const question = match.questions[questionIndex];
        const isCorrect = answer === question.correctAnswer;

        const isPlayer1 = match.player1.uid === userId;
        const playerKey = isPlayer1 ? "player1" : "player2";
        const currentScore = isPlayer1 ? match.player1.score : match.player2?.score || 0;
        const newScore = isCorrect ? currentScore + 10 : currentScore;

        const currentAnswers = isPlayer1 ? match.player1.answers || [] : match.player2?.answers || [];
        await matchRef.child(playerKey).update({
          answers: [...currentAnswers, { questionIndex, answer, correct: isCorrect }],
          score: newScore,
        });

        const updatedMatch = (await matchRef.once("value")).val();
        const player1Done = (updatedMatch.player1.answers?.length || 0) >= match.questions.length;
        const player2Done = (updatedMatch.player2?.answers?.length || 0) >= match.questions.length;

        if (player1Done && player2Done) {
          const winner = updatedMatch.player1.score > (updatedMatch.player2?.score || 0)
            ? updatedMatch.player1.uid
            : updatedMatch.player1.score < (updatedMatch.player2?.score || 0)
            ? updatedMatch.player2?.uid
            : "tie";

          await matchRef.update({ status: "completed", winner, endTime: new Date().toISOString() });

          return jsonResponse({
            success: true,
            isCorrect,
            newScore,
            matchComplete: true,
            winner,
            finalScores: { player1: updatedMatch.player1.score, player2: updatedMatch.player2?.score || 0 },
          });
        }

        return jsonResponse({ success: true, isCorrect, newScore, correctAnswer: question.correctAnswer, matchComplete: false });
      }

      case "leave_match": {
        if (!matchId) return errorResponse("Match ID required");

        const matchRef = matchesRef.child(matchId);
        const match = (await matchRef.once("value")).val();

        if (!match) return errorResponse("Match not found", 404);

        if (match.status === "waiting") {
          await matchRef.remove();
        } else {
          const isPlayer1 = match.player1.uid === userId;
          const winner = isPlayer1 ? match.player2?.uid : match.player1.uid;
          await matchRef.update({ status: "completed", winner, forfeitedBy: userId, endTime: new Date().toISOString() });
        }

        return jsonResponse({ success: true, message: "Left match" });
      }

      case "get_match": {
        if (!matchId) return errorResponse("Match ID required");

        const match = (await matchesRef.child(matchId).once("value")).val();
        if (!match) return errorResponse("Match not found", 404);

        return jsonResponse({ success: true, match });
      }

      default:
        return errorResponse("Invalid action");
    }
  } catch (error) {
    console.error("Error:", error);
    return errorResponse(error.message || "Internal server error", 500);
  }
});
