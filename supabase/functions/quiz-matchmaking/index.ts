// Quiz Matchmaking Function
// Handles multiplayer quiz match creation and joining

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { initializeFirebase, warmupFirebase } from "../_shared/firebase-rest.ts";
import { corsHeaders, handleCors, jsonResponse, errorResponse, verifyAuthTokenLight } from "../_shared/cors.ts";

interface QuizMatch {
  matchId: string;
  player1: {
    uid: string;
    displayName: string;
    avatarUrl?: string;
    ready: boolean;
    score: number;
    answers: Array<{ questionIndex: number; answer: number; correct: boolean; time: number }>;
  };
  player2?: {
    uid: string;
    displayName: string;
    avatarUrl?: string;
    ready: boolean;
    score: number;
    answers: Array<{ questionIndex: number; answer: number; correct: boolean; time: number }>;
  };
  status: 'waiting' | 'matched' | 'starting' | 'in_progress' | 'completed' | 'cancelled';
  category: string;
  questions: Array<{
    question: string;
    options: string[];
    correctAnswer: number;
  }>;
  currentQuestionIndex: number;
  startTime?: string;
  endTime?: string;
  winner?: string;
  createdAt: string;
  updatedAt: string;
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Start warmup early
    const warmupPromise = warmupFirebase();

    // Get request body
    const { action, matchId, category = 'general', answer, questionIndex } = await req.json();

    // Verify authentication (in parallel with warmup)
    const [authResult] = await Promise.all([
      verifyAuthTokenLight(req),
      warmupPromise,
    ]);
    if (!authResult) {
      return errorResponse("Unauthorized", 401);
    }

    const { db, rtdb } = initializeFirebase();
    const userId = authResult.uid;

    // Get user profile
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return errorResponse("User not found", 404);
    }

    const userData = userDoc.data()!;
    const userProfile = {
      uid: userId,
      displayName: userData.displayName || 'Player',
      avatarUrl: userData.avatarUrl,
      ready: false,
      score: 0,
      answers: [],
    };

    switch (action) {
      case 'find_match':
        return await findOrCreateMatch(rtdb, userProfile, category);

      case 'join_match':
        if (!matchId) {
          return errorResponse("Match ID required");
        }
        return await joinMatch(rtdb, matchId, userProfile);

      case 'ready':
        if (!matchId) {
          return errorResponse("Match ID required");
        }
        return await setReady(rtdb, matchId, userId);

      case 'submit_answer':
        if (!matchId || answer === undefined || questionIndex === undefined) {
          return errorResponse("Match ID, answer, and questionIndex required");
        }
        return await submitAnswer(rtdb, matchId, userId, questionIndex, answer);

      case 'leave_match':
        if (!matchId) {
          return errorResponse("Match ID required");
        }
        return await leaveMatch(rtdb, matchId, userId);

      case 'get_match':
        if (!matchId) {
          return errorResponse("Match ID required");
        }
        return await getMatch(rtdb, matchId);

      default:
        return errorResponse("Invalid action. Use: find_match, join_match, ready, submit_answer, leave_match, get_match");
    }
  } catch (error) {
    console.error("Error in quiz matchmaking:", error);
    return errorResponse(error.message, 500);
  }
});

// Find an existing waiting match or create a new one
async function findOrCreateMatch(rtdb: any, userProfile: any, category: string) {
  const matchesRef = rtdb.ref('quizMatches');

  // Look for an existing waiting match in this category
  const waitingMatches = await matchesRef
    .orderByChild('status')
    .equalTo('waiting')
    .once('value');

  let matchData = waitingMatches.val();
  let foundMatchId: string | null = null;

  if (matchData) {
    // Find a match in the same category that isn't the current user's
    for (const [id, match] of Object.entries(matchData) as [string, any][]) {
      if (match.category === category && match.player1.uid !== userProfile.uid) {
        foundMatchId = id;
        break;
      }
    }
  }

  if (foundMatchId) {
    // Join existing match
    return await joinMatch(rtdb, foundMatchId, userProfile);
  }

  // Create new match
  const newMatchRef = matchesRef.push();
  const matchId = newMatchRef.key;

  const questions = generateQuizQuestions(category, 10);

  const newMatch: QuizMatch = {
    matchId,
    player1: userProfile,
    status: 'waiting',
    category,
    questions,
    currentQuestionIndex: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  await newMatchRef.set(newMatch);

  return jsonResponse({
    success: true,
    action: 'created',
    matchId,
    match: {
      ...newMatch,
      questions: undefined, // Don't send questions yet
    },
  });
}

// Join an existing match
async function joinMatch(rtdb: any, matchId: string, userProfile: any) {
  const matchRef = rtdb.ref(`quizMatches/${matchId}`);
  const matchSnapshot = await matchRef.once('value');

  if (!matchSnapshot.exists()) {
    return errorResponse("Match not found", 404);
  }

  const match = matchSnapshot.val() as QuizMatch;

  if (match.status !== 'waiting') {
    return errorResponse("Match is not available for joining");
  }

  if (match.player1.uid === userProfile.uid) {
    return errorResponse("Cannot join your own match");
  }

  // Update match with player 2
  await matchRef.update({
    player2: userProfile,
    status: 'matched',
    updatedAt: new Date().toISOString(),
  });

  return jsonResponse({
    success: true,
    action: 'joined',
    matchId,
    opponent: {
      uid: match.player1.uid,
      displayName: match.player1.displayName,
      avatarUrl: match.player1.avatarUrl,
    },
  });
}

// Set player as ready
async function setReady(rtdb: any, matchId: string, userId: string) {
  const matchRef = rtdb.ref(`quizMatches/${matchId}`);
  const matchSnapshot = await matchRef.once('value');

  if (!matchSnapshot.exists()) {
    return errorResponse("Match not found", 404);
  }

  const match = matchSnapshot.val() as QuizMatch;

  const isPlayer1 = match.player1.uid === userId;
  const isPlayer2 = match.player2?.uid === userId;

  if (!isPlayer1 && !isPlayer2) {
    return errorResponse("You are not part of this match");
  }

  const playerKey = isPlayer1 ? 'player1' : 'player2';
  await matchRef.child(playerKey).update({ ready: true });

  // Check if both players are ready
  const updatedSnapshot = await matchRef.once('value');
  const updatedMatch = updatedSnapshot.val() as QuizMatch;

  if (updatedMatch.player1.ready && updatedMatch.player2?.ready) {
    // Start the match
    await matchRef.update({
      status: 'in_progress',
      startTime: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    return jsonResponse({
      success: true,
      status: 'starting',
      questions: updatedMatch.questions.map((q) => ({
        question: q.question,
        options: q.options,
      })), // Don't send correct answers
    });
  }

  return jsonResponse({
    success: true,
    status: 'waiting_for_opponent',
  });
}

// Submit an answer
async function submitAnswer(rtdb: any, matchId: string, userId: string, questionIndex: number, answer: number) {
  const matchRef = rtdb.ref(`quizMatches/${matchId}`);
  const matchSnapshot = await matchRef.once('value');

  if (!matchSnapshot.exists()) {
    return errorResponse("Match not found", 404);
  }

  const match = matchSnapshot.val() as QuizMatch;

  if (match.status !== 'in_progress') {
    return errorResponse("Match is not in progress");
  }

  const isPlayer1 = match.player1.uid === userId;
  const isPlayer2 = match.player2?.uid === userId;

  if (!isPlayer1 && !isPlayer2) {
    return errorResponse("You are not part of this match");
  }

  const question = match.questions[questionIndex];
  if (!question) {
    return errorResponse("Invalid question index");
  }

  const isCorrect = answer === question.correctAnswer;
  const timeNow = Date.now();
  const startTime = new Date(match.startTime!).getTime();
  const timeTaken = Math.floor((timeNow - startTime) / 1000);

  const answerData = {
    questionIndex,
    answer,
    correct: isCorrect,
    time: timeTaken,
  };

  const playerKey = isPlayer1 ? 'player1' : 'player2';
  const currentScore = isPlayer1 ? match.player1.score : match.player2?.score || 0;
  const newScore = isCorrect ? currentScore + 10 : currentScore;

  // Update player's answers and score
  const currentAnswers = isPlayer1 ? match.player1.answers || [] : match.player2?.answers || [];
  await matchRef.child(playerKey).update({
    answers: [...currentAnswers, answerData],
    score: newScore,
  });

  // Check if both players have answered all questions
  const updatedSnapshot = await matchRef.once('value');
  const updatedMatch = updatedSnapshot.val() as QuizMatch;

  const player1Done = (updatedMatch.player1.answers?.length || 0) >= match.questions.length;
  const player2Done = (updatedMatch.player2?.answers?.length || 0) >= match.questions.length;

  if (player1Done && player2Done) {
    // Match complete - determine winner
    const winner = updatedMatch.player1.score > (updatedMatch.player2?.score || 0)
      ? updatedMatch.player1.uid
      : updatedMatch.player1.score < (updatedMatch.player2?.score || 0)
      ? updatedMatch.player2?.uid
      : 'tie';

    await matchRef.update({
      status: 'completed',
      winner,
      endTime: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    return jsonResponse({
      success: true,
      isCorrect,
      newScore,
      matchComplete: true,
      winner,
      finalScores: {
        player1: updatedMatch.player1.score,
        player2: updatedMatch.player2?.score || 0,
      },
    });
  }

  return jsonResponse({
    success: true,
    isCorrect,
    newScore,
    correctAnswer: question.correctAnswer,
    matchComplete: false,
  });
}

// Leave a match
async function leaveMatch(rtdb: any, matchId: string, userId: string) {
  const matchRef = rtdb.ref(`quizMatches/${matchId}`);
  const matchSnapshot = await matchRef.once('value');

  if (!matchSnapshot.exists()) {
    return errorResponse("Match not found", 404);
  }

  const match = matchSnapshot.val() as QuizMatch;

  const isPlayer1 = match.player1.uid === userId;
  const isPlayer2 = match.player2?.uid === userId;

  if (!isPlayer1 && !isPlayer2) {
    return errorResponse("You are not part of this match");
  }

  if (match.status === 'waiting') {
    // Delete the match if no one has joined
    await matchRef.remove();
  } else if (match.status === 'matched' || match.status === 'in_progress') {
    // Forfeit - other player wins
    const winner = isPlayer1 ? match.player2?.uid : match.player1.uid;
    await matchRef.update({
      status: 'completed',
      winner,
      endTime: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      forfeitedBy: userId,
    });
  }

  return jsonResponse({
    success: true,
    message: "Left match successfully",
  });
}

// Get match details
async function getMatch(rtdb: any, matchId: string) {
  const matchRef = rtdb.ref(`quizMatches/${matchId}`);
  const matchSnapshot = await matchRef.once('value');

  if (!matchSnapshot.exists()) {
    return errorResponse("Match not found", 404);
  }

  const match = matchSnapshot.val() as QuizMatch;

  // Don't send questions with answers unless match is completed
  const sanitizedMatch = {
    ...match,
    questions: match.status === 'completed'
      ? match.questions
      : match.questions.map((q) => ({
          question: q.question,
          options: q.options,
        })),
  };

  return jsonResponse({
    success: true,
    match: sanitizedMatch,
  });
}

// Generate quiz questions for a category
function generateQuizQuestions(category: string, count: number): Array<{
  question: string;
  options: string[];
  correctAnswer: number;
}> {
  // Sample financial literacy questions
  const questionBank = [
    {
      question: "What is the 50/30/20 budgeting rule?",
      options: [
        "50% needs, 30% wants, 20% savings",
        "50% savings, 30% needs, 20% wants",
        "50% wants, 30% savings, 20% needs",
        "50% investments, 30% savings, 20% spending"
      ],
      correctAnswer: 0,
    },
    {
      question: "What does SIP stand for in investing?",
      options: [
        "Standard Investment Plan",
        "Systematic Investment Plan",
        "Secure Investment Protocol",
        "Simple Interest Plan"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is compound interest?",
      options: [
        "Interest only on the principal amount",
        "Interest on both principal and accumulated interest",
        "A fixed rate of interest",
        "Interest that decreases over time"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is an emergency fund?",
      options: [
        "Money for buying luxury items",
        "Money saved for retirement",
        "Money set aside for unexpected expenses",
        "Money invested in stocks"
      ],
      correctAnswer: 2,
    },
    {
      question: "What is diversification in investing?",
      options: [
        "Putting all money in one stock",
        "Spreading investments across different assets",
        "Investing only in real estate",
        "Saving money in a bank account"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is inflation?",
      options: [
        "Decrease in money supply",
        "Increase in the general price level over time",
        "A type of tax",
        "Interest earned on savings"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is a credit score?",
      options: [
        "Your total income",
        "A number representing your creditworthiness",
        "The amount you owe",
        "Your bank account balance"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is a mutual fund?",
      options: [
        "A personal savings account",
        "A pool of money from multiple investors",
        "A type of loan",
        "Government bonds only"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is the power of compounding best described as?",
      options: [
        "Interest on interest",
        "Simple interest calculation",
        "Tax-free returns",
        "Government subsidies"
      ],
      correctAnswer: 0,
    },
    {
      question: "What should you do before investing?",
      options: [
        "Borrow money to invest more",
        "Build an emergency fund first",
        "Invest in high-risk stocks immediately",
        "Ignore your debts"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is a budget?",
      options: [
        "A list of things you want to buy",
        "A plan for spending and saving money",
        "Your total wealth",
        "A type of investment"
      ],
      correctAnswer: 1,
    },
    {
      question: "What is the recommended months of expenses for an emergency fund?",
      options: [
        "1-2 months",
        "3-6 months",
        "12 months",
        "No specific amount"
      ],
      correctAnswer: 1,
    },
  ];

  // Shuffle and select questions
  const shuffled = [...questionBank].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(count, shuffled.length));
}
