import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Client-Side Game Logic Service
///
/// Replaces Cloud Functions for free tier
/// All business logic runs on the client
class GameLogicService {
  // Singleton pattern
  static final GameLogicService _instance = GameLogicService._internal();
  factory GameLogicService() => _instance;
  GameLogicService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // ============================================
  // LIFE SWIPE GAME
  // ============================================

  /// Submit Life Swipe game result
  Future<Map<String, dynamic>> submitLifeSwipe({
    required int seed,
    required Map<String, int> allocations,
    required int score,
    List<dynamic>? eventChoices,
  }) async {
    try {
      // Calculate rewards based on score
      final int xpReward = (score * 0.5).round(); // 0.5 XP per score point
      final int coinsReward = (score * 0.1).round(); // 0.1 coins per score point

      // Validate score (basic anti-cheat)
      if (score > 1000 || score < 0) {
        throw Exception('Invalid score');
      }

      // Use Firestore transaction to update user data atomically
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentXP = (userDoc.data()?['xp'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        final newXP = currentXP + xpReward;
        final newCoins = currentCoins + coinsReward;

        // Level up logic (every 1000 XP)
        final newLevel = (newXP / 1000).floor() + 1;

        // Update user profile
        transaction.update(userRef, {
          'xp': newXP,
          'coins': newCoins,
          'level': newLevel,
          'lastActiveDate': DateTime.now().toIso8601String().split('T')[0],
          'gamesPlayed': FieldValue.increment(1),
        });

        // Save game progress
        final progressRef = userRef.collection('progress').doc('life_swipe');
        transaction.set(
          progressRef,
          {
            'lastScore': score,
            'bestScore': FieldValue.serverTimestamp(), // Will be updated by another query
            'totalPlays': FieldValue.increment(1),
            'lastPlayedAt': FieldValue.serverTimestamp(),
            'allocations': allocations,
            'seed': seed,
          },
          SetOptions(merge: true),
        );

        // Update best score if applicable
        final progressDoc = await progressRef.get();
        final currentBest = (progressDoc.data()?['bestScore'] ?? 0) as int;
        if (score > currentBest) {
          transaction.update(progressRef, {'bestScore': score});
        }
      });

      // Update achievement progress for first game and games milestones
      await _updateGameAchievements();

      return {
        'success': true,
        'xpEarned': xpReward,
        'coinsEarned': coinsReward,
        'message': 'Game saved successfully!',
      };
    } catch (e) {
      debugPrint('submitLifeSwipe error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============================================
  // BUDGET BLITZ GAME
  // ============================================

  /// Submit Budget Blitz result
  Future<Map<String, dynamic>> submitBudgetBlitz({
    required int score,
    required int level,
    required int correctDecisions,
    required int totalDecisions,
  }) async {
    try {
      final int xpReward = score ~/ 2;
      final int coinsReward = score ~/ 5;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        final currentXP = (userDoc.data()?['xp'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        final newXP = currentXP + xpReward;
        final newCoins = currentCoins + coinsReward;
        final newLevel = (newXP / 1000).floor() + 1;

        transaction.update(userRef, {
          'xp': newXP,
          'coins': newCoins,
          'level': newLevel,
          'gamesPlayed': FieldValue.increment(1),
        });

        // Save progress
        final progressRef = userRef.collection('progress').doc('budget_blitz');
        transaction.set(
          progressRef,
          {
            'lastScore': score,
            'highestLevel': FieldValue.serverTimestamp(), // Updated separately
            'totalPlays': FieldValue.increment(1),
            'lastPlayedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });

      // Update achievement progress for first game and games milestones
      await _updateGameAchievements();

      return {
        'success': true,
        'xpEarned': xpReward,
        'coinsEarned': coinsReward,
      };
    } catch (e) {
      debugPrint('submitBudgetBlitz error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // QUIZ BATTLE GAME
  // ============================================

  /// Submit Quiz Battle result
  Future<Map<String, dynamic>> submitQuizBattle({
    required int correctAnswers,
    required int totalQuestions,
    required int timeBonus,
  }) async {
    try {
      // Calculate score
      final score = (correctAnswers * 10) + timeBonus;
      final int xpReward = score ~/ 2;
      final int coinsReward = score ~/ 5;

      // Bonus for perfect score
      final isPerfect = correctAnswers == totalQuestions;
      final bonusXp = isPerfect ? 50 : 0;
      final bonusCoins = isPerfect ? 25 : 0;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        final currentXP = (userDoc.data()?['xp'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        final newXP = currentXP + xpReward + bonusXp;
        final newCoins = currentCoins + coinsReward + bonusCoins;
        final newLevel = (newXP / 1000).floor() + 1;

        transaction.update(userRef, {
          'xp': newXP,
          'coins': newCoins,
          'level': newLevel,
          'gamesPlayed': FieldValue.increment(1),
        });

        // Save progress
        final progressRef = userRef.collection('progress').doc('quiz_battle');
        transaction.set(
          progressRef,
          {
            'lastScore': score,
            'totalPlays': FieldValue.increment(1),
            'lastPlayedAt': FieldValue.serverTimestamp(),
            'correctAnswers': correctAnswers,
            'totalQuestions': totalQuestions,
          },
          SetOptions(merge: true),
        );
      });

      await _updateGameAchievements();

      return {
        'success': true,
        'xpEarned': xpReward + bonusXp,
        'coinsEarned': coinsReward + bonusCoins,
      };
    } catch (e) {
      debugPrint('submitQuizBattle error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // MARKET EXPLORER GAME
  // ============================================

  /// Submit Market Explorer result
  Future<Map<String, dynamic>> submitMarketExplorer({
    required double portfolioValue,
    required double initialValue,
    required Map<String, double> portfolio,
    required int decisionsCount,
  }) async {
    try {
      // Calculate return percentage
      final returnPct = ((portfolioValue - initialValue) / initialValue) * 100;

      // Calculate rewards based on performance
      int xpReward = 30;
      int coinsReward = 15;

      if (returnPct > 50) {
        xpReward += 70;
        coinsReward += 35;
      } else if (returnPct > 25) {
        xpReward += 50;
        coinsReward += 25;
      } else if (returnPct > 10) {
        xpReward += 30;
        coinsReward += 15;
      } else if (returnPct > 0) {
        xpReward += 15;
        coinsReward += 8;
      }

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        final currentXP = (userDoc.data()?['xp'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        final newXP = currentXP + xpReward;
        final newCoins = currentCoins + coinsReward;
        final newLevel = (newXP / 1000).floor() + 1;

        transaction.update(userRef, {
          'xp': newXP,
          'coins': newCoins,
          'level': newLevel,
          'gamesPlayed': FieldValue.increment(1),
        });

        // Save progress
        final progressRef = userRef.collection('progress').doc('market_explorer');
        transaction.set(
          progressRef,
          {
            'lastPortfolioValue': portfolioValue,
            'lastReturnPct': returnPct,
            'totalPlays': FieldValue.increment(1),
            'lastPlayedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });

      await _updateGameAchievements();

      return {
        'success': true,
        'xpEarned': xpReward,
        'coinsEarned': coinsReward,
      };
    } catch (e) {
      debugPrint('submitMarketExplorer error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // LESSONS
  // ============================================

  /// Complete a lesson
  Future<Map<String, dynamic>> completeLesson(
      String lessonId, int quizScore) async {
    try {
      // Reward: 50 XP + 10 coins per lesson
      const int xpReward = 50;
      const int coinsReward = 10;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        final currentXP = (userDoc.data()?['xp'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        final newXP = currentXP + xpReward;
        final newCoins = currentCoins + coinsReward;
        final newLevel = (newXP / 1000).floor() + 1;

        transaction.update(userRef, {
          'xp': newXP,
          'coins': newCoins,
          'level': newLevel,
          'lessonsCompleted': FieldValue.increment(1),
        });

        // Save lesson progress
        final progressRef =
            userRef.collection('lessonProgress').doc(lessonId);
        transaction.set(progressRef, {
          'completed': true,
          'quizScore': quizScore,
          'completedAt': FieldValue.serverTimestamp(),
        });
      });

      // Update achievement progress for learning milestones
      await _updateLessonAchievements();

      return {
        'success': true,
        'xpEarned': xpReward,
        'coinsEarned': coinsReward,
      };
    } catch (e) {
      debugPrint('completeLesson error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // DAILY CHECK-IN & STREAKS
  // ============================================

  /// Daily check-in (manually triggered by user)
  Future<Map<String, dynamic>> dailyCheckIn() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      Map<String, dynamic>? result;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        final lastActiveDate = userDoc.data()?['lastActiveDate'] as String?;
        final currentStreak = (userDoc.data()?['streakDays'] ?? 0) as int;

        if (lastActiveDate == today) {
          result = {
            'success': false,
            'message': 'Already checked in today!',
            'streak': currentStreak,
          };
          return;
        }

        // Calculate new streak
        final yesterday =
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
        final newStreak = (lastActiveDate == yesterday) ? currentStreak + 1 : 1;

        // Reward: 20 XP + 5 coins per day, bonus for streaks
        final streakBonus = (newStreak ~/ 7) * 10; // Bonus every 7 days
        final xpReward = 20 + streakBonus;
        final coinsReward = 5 + (streakBonus ~/ 2);

        final currentXP = (userDoc.data()?['xp'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        final newXP = currentXP + xpReward;
        final newCoins = currentCoins + coinsReward;
        final newLevel = (newXP / 1000).floor() + 1;

        transaction.update(userRef, {
          'xp': newXP,
          'coins': newCoins,
          'level': newLevel,
          'streakDays': newStreak,
          'lastActiveDate': today,
        });

        result = {
          'success': true,
          'streak': newStreak,
          'xpEarned': xpReward,
          'coinsEarned': coinsReward,
          'message': 'Check-in successful! $newStreak day streak!',
        };
      });

      // Update streak achievements after successful check-in
      if (result != null && result!['success'] == true) {
        await _updateStreakAchievements(result!['streak'] as int);
      }

      return result ?? {'success': false};
    } catch (e) {
      debugPrint('dailyCheckIn error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // STORE & PURCHASES
  // ============================================

  /// Purchase item from store
  Future<Map<String, dynamic>> purchaseItem(String itemId) async {
    try {
      Map<String, dynamic>? result;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await transaction.get(userRef);

        // Get item details
        final itemDoc = await _firestore
            .collection('store')
            .doc('items')
            .collection('all')
            .doc(itemId)
            .get();

        if (!itemDoc.exists) {
          result = {'success': false, 'error': 'Item not found'};
          return;
        }

        final itemPrice = (itemDoc.data()?['price'] ?? 0) as int;
        final currentCoins = (userDoc.data()?['coins'] ?? 0) as int;

        if (currentCoins < itemPrice) {
          result = {'success': false, 'error': 'Not enough coins'};
          return;
        }

        // Deduct coins
        transaction.update(userRef, {
          'coins': currentCoins - itemPrice,
        });

        // Add to inventory
        final inventoryRef = userRef.collection('inventory').doc(itemId);
        transaction.set(inventoryRef, {
          'itemId': itemId,
          'purchasedAt': FieldValue.serverTimestamp(),
          'equipped': false,
        });

        result = {
          'success': true,
          'message': 'Purchase successful!',
          'coinsSpent': itemPrice,
        };
      });

      return result ?? {'success': false};
    } catch (e) {
      debugPrint('purchaseItem error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================
  // ACHIEVEMENTS
  // ============================================

  /// Check and unlock achievements (called after any progress)
  Future<void> checkAchievements() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(_userId).get();
      final xp = (userDoc.data()?['xp'] ?? 0) as int;
      final level = (userDoc.data()?['level'] ?? 1) as int;
      final streak = (userDoc.data()?['streakDays'] ?? 0) as int;

      // Example achievement checks
      final achievements = <String, bool>{
        'first_game': xp > 0,
        'level_5': level >= 5,
        'level_10': level >= 10,
        'streak_7': streak >= 7,
        'streak_30': streak >= 30,
      };

      // Check existing achievements
      final existingAchievements = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements')
          .get();

      final unlockedIds =
          existingAchievements.docs.map((doc) => doc.id).toSet();

      // Unlock new achievements
      for (final entry in achievements.entries) {
        if (entry.value && !unlockedIds.contains(entry.key)) {
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('achievements')
              .doc(entry.key)
              .set({
            'achievementId': entry.key,
            'unlockedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('Achievement unlocked: ${entry.key}');
        }
      }
    } catch (e) {
      debugPrint('checkAchievements error: $e');
    }
  }

  // ============================================
  // ACHIEVEMENT HELPERS
  // ============================================

  /// Update game-related achievements
  Future<void> _updateGameAchievements() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      final gamesPlayed = (userDoc.data()?['gamesPlayed'] ?? 0) as int;
      final coins = (userDoc.data()?['coins'] ?? 0) as int;

      final batch = _firestore.batch();
      final achievementsRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements');

      // First game achievement
      if (gamesPlayed >= 1) {
        final firstGameDoc = await achievementsRef.doc('first_game').get();
        if (firstGameDoc.exists && !(firstGameDoc.data()?['unlocked'] ?? false)) {
          batch.update(achievementsRef.doc('first_game'), {
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'currentProgress': 1,
          });
          // Award rewards
          batch.update(_firestore.collection('users').doc(_userId), {
            'xp': FieldValue.increment(100),
            'coins': FieldValue.increment(50),
          });
          debugPrint('Achievement unlocked: first_game');
        }
      }

      // 10 games achievement
      if (gamesPlayed >= 10) {
        final gamesDoc = await achievementsRef.doc('games_10').get();
        if (gamesDoc.exists && !(gamesDoc.data()?['unlocked'] ?? false)) {
          batch.update(achievementsRef.doc('games_10'), {
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'currentProgress': 10,
          });
          batch.update(_firestore.collection('users').doc(_userId), {
            'xp': FieldValue.increment(500),
            'coins': FieldValue.increment(200),
          });
          debugPrint('Achievement unlocked: games_10');
        }
      }

      // Update game progress for games_10 achievement
      final gamesDoc = await achievementsRef.doc('games_10').get();
      if (gamesDoc.exists && !(gamesDoc.data()?['unlocked'] ?? false)) {
        batch.update(achievementsRef.doc('games_10'), {
          'currentProgress': gamesPlayed,
        });
      }

      // 1000 coins achievement
      if (coins >= 1000) {
        final coinsDoc = await achievementsRef.doc('coins_1000').get();
        if (coinsDoc.exists && !(coinsDoc.data()?['unlocked'] ?? false)) {
          batch.update(achievementsRef.doc('coins_1000'), {
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'currentProgress': coins,
          });
          batch.update(_firestore.collection('users').doc(_userId), {
            'xp': FieldValue.increment(600),
            'coins': FieldValue.increment(250),
          });
          debugPrint('Achievement unlocked: coins_1000');
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('_updateGameAchievements error: $e');
    }
  }

  /// Update lesson-related achievements
  Future<void> _updateLessonAchievements() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      final lessonsCompleted = (userDoc.data()?['lessonsCompleted'] ?? 0) as int;

      final batch = _firestore.batch();
      final achievementsRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements');

      // 5 lessons achievement
      if (lessonsCompleted >= 5) {
        final lessonsDoc = await achievementsRef.doc('lessons_5').get();
        if (lessonsDoc.exists && !(lessonsDoc.data()?['unlocked'] ?? false)) {
          batch.update(achievementsRef.doc('lessons_5'), {
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'currentProgress': 5,
          });
          batch.update(_firestore.collection('users').doc(_userId), {
            'xp': FieldValue.increment(400),
            'coins': FieldValue.increment(150),
          });
          debugPrint('Achievement unlocked: lessons_5');
        }
      }

      // Update progress for lessons_5 achievement
      final lessonsDoc = await achievementsRef.doc('lessons_5').get();
      if (lessonsDoc.exists && !(lessonsDoc.data()?['unlocked'] ?? false)) {
        batch.update(achievementsRef.doc('lessons_5'), {
          'currentProgress': lessonsCompleted,
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('_updateLessonAchievements error: $e');
    }
  }

  /// Update streak-related achievements (called during daily check-in)
  Future<void> _updateStreakAchievements(int streakDays) async {
    try {
      final batch = _firestore.batch();
      final achievementsRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements');

      // 3-day streak achievement
      if (streakDays >= 3) {
        final streak3Doc = await achievementsRef.doc('streak_3').get();
        if (streak3Doc.exists && !(streak3Doc.data()?['unlocked'] ?? false)) {
          batch.update(achievementsRef.doc('streak_3'), {
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'currentProgress': 3,
          });
          batch.update(_firestore.collection('users').doc(_userId), {
            'xp': FieldValue.increment(150),
            'coins': FieldValue.increment(75),
          });
          debugPrint('Achievement unlocked: streak_3');
        }
      }

      // 7-day streak achievement
      if (streakDays >= 7) {
        final streak7Doc = await achievementsRef.doc('streak_7').get();
        if (streak7Doc.exists && !(streak7Doc.data()?['unlocked'] ?? false)) {
          batch.update(achievementsRef.doc('streak_7'), {
            'unlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
            'currentProgress': 7,
          });
          batch.update(_firestore.collection('users').doc(_userId), {
            'xp': FieldValue.increment(300),
            'coins': FieldValue.increment(150),
          });
          debugPrint('Achievement unlocked: streak_7');
        }
      }

      // Update progress for streak achievements
      final streak3Doc = await achievementsRef.doc('streak_3').get();
      if (streak3Doc.exists && !(streak3Doc.data()?['unlocked'] ?? false)) {
        batch.update(achievementsRef.doc('streak_3'), {
          'currentProgress': streakDays,
        });
      }

      final streak7Doc = await achievementsRef.doc('streak_7').get();
      if (streak7Doc.exists && !(streak7Doc.data()?['unlocked'] ?? false)) {
        batch.update(achievementsRef.doc('streak_7'), {
          'currentProgress': streakDays,
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('_updateStreakAchievements error: $e');
    }
  }
}
