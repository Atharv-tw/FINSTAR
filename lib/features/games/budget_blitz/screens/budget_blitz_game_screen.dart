import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/design_tokens.dart';
import '../../../../services/game_logic_service.dart';
import '../models/expense.dart';

class BudgetBlitzGameScreen extends StatefulWidget {
  const BudgetBlitzGameScreen({super.key});

  @override
  State<BudgetBlitzGameScreen> createState() => _BudgetBlitzGameScreenState();
}

class _BudgetBlitzGameScreenState extends State<BudgetBlitzGameScreen>
    with TickerProviderStateMixin {
  int _score = 0;
  int _highScore = 0;
  int _level = 1;
  bool _gameStarted = false;
  bool _gameOver = false;
  String _gameOverReason = '';
  int _xpEarned = 0;
  int _coinsEarned = 0;
  int _correctDecisions = 0;
  int _totalDecisions = 0;

  Timer? _spawnTimer;
  int _gameSpeed = 2000; // milliseconds
  final List<FallingExpense> _fallingExpenses = [];
  final Random _random = Random();
  List<Expense> _shuffledExpenses = [];
  int _expenseIndex = 0;
  final GameLogicService _gameLogic = GameLogicService();

  // Score thresholds for popups
  final Map<int, String> _scoreMessages = {
    30: "Amazing!",
    50: "Fast Reactor!",
    70: "Keep it up!",
    100: "Budget Master!",
  };
  final Set<int> _triggeredMessages = {};
  String _currentPopupMessage = '';
  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    for (var expense in _fallingExpenses) {
      expense.controller.dispose();
    }
    super.dispose();
  }

  void _loadHighScore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final progressDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('budget_blitz')
          .get();

      if (progressDoc.exists && mounted) {
        setState(() {
          _highScore = progressDoc.data()?['bestScore'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading high score: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      if (_score > _highScore) {
        _highScore = _score;
      }

      // Submit to Firebase and get rewards
      final result = await _gameLogic.submitBudgetBlitz(
        score: _score,
        level: _level,
        correctDecisions: _correctDecisions,
        totalDecisions: _totalDecisions,
      );

      if (result['success'] == true && mounted) {
        setState(() {
          _xpEarned = result['xpEarned'] ?? 0;
          _coinsEarned = result['coinsEarned'] ?? 0;
        });
      }
    } catch (e) {
      print('Error saving high score: $e');
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _gameSpeed = 2000;
      _gameStarted = true;
      _gameOver = false;
      _gameOverReason = '';
      _xpEarned = 0;
      _coinsEarned = 0;
      _correctDecisions = 0;
      _totalDecisions = 0;
      _triggeredMessages.clear();
      _fallingExpenses.clear();

      // Shuffle the expenses list for better variety
      _shuffledExpenses = List.from(allExpenses)..shuffle(_random);
      _expenseIndex = 0;
    });

    _spawnExpense();
    _startSpawnTimer();
  }

  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer(Duration(milliseconds: _gameSpeed), () {
      if (_gameStarted && !_gameOver) {
        _spawnExpense();
        _updateDifficulty();
        _startSpawnTimer();
      }
    });
  }

  void _updateDifficulty() {
    if (_gameSpeed > 500) {
      _gameSpeed -= 25;
    }
    final newLevel = ((2000 - _gameSpeed) / 150).floor() + 1;
    if (newLevel != _level) {
      setState(() {
        _level = newLevel;
      });
    }
  }

  void _spawnExpense() {
    // Get next expense from shuffled list, reshuffle when we reach the end
    if (_expenseIndex >= _shuffledExpenses.length) {
      _shuffledExpenses.shuffle(_random);
      _expenseIndex = 0;
    }

    final expense = _shuffledExpenses[_expenseIndex];
    _expenseIndex++;

    final controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    final fallingExpense = FallingExpense(
      expense: expense,
      controller: controller,
      startX: _random.nextDouble() * 0.7 + 0.1, // 10% to 80% of screen width
    );

    setState(() {
      _fallingExpenses.add(fallingExpense);
    });

    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Expense reached bottom without being sorted
        if (_gameStarted && !_gameOver) {
          _endGame("You missed an expense!");
        }
      }
    });
  }

  void _onExpenseDropped(FallingExpense fallingExpense, ExpenseCategory droppedCategory) {
    _totalDecisions++;

    if (fallingExpense.expense.category == droppedCategory) {
      // Correct!
      _correctDecisions++;
      _updateScore(10);
      _removeFallingExpense(fallingExpense);
    } else {
      // Wrong category
      _endGame(fallingExpense.expense.explanation);
    }
  }

  void _updateScore(int points) {
    setState(() {
      _score += points;
    });

    // Check for milestone messages
    for (var entry in _scoreMessages.entries) {
      if (_score >= entry.key && !_triggeredMessages.contains(entry.key)) {
        _triggeredMessages.add(entry.key);
        _showMilestonePopup(entry.value);
        break;
      }
    }
  }

  void _showMilestonePopup(String message) {
    setState(() {
      _currentPopupMessage = message;
      _showPopup = true;
    });

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showPopup = false;
        });
      }
    });
  }

  void _removeFallingExpense(FallingExpense fallingExpense) {
    setState(() {
      _fallingExpenses.remove(fallingExpense);
    });
    fallingExpense.controller.dispose();
  }

  void _endGame(String reason) async {
    _spawnTimer?.cancel();

    setState(() {
      _gameOver = true;
      _gameOverReason = reason;
      _gameStarted = false;
    });

    // Dispose all falling expenses
    for (var expense in _fallingExpenses) {
      expense.controller.dispose();
    }
    _fallingExpenses.clear();

    // Save score and get rewards
    await _saveHighScore();
  }

  void _restartGame() {
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted && !_gameOver) {
      return _buildStartScreen();
    } else if (_gameOver) {
      return _buildEndScreen();
    } else {
      return _buildGameScreen();
    }
  }

  Widget _buildStartScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: DesignTokens.textDarkPrimary, size: 28),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.pop();
                  },
                ),
              ),
              // Content
              Center(
                child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Panda mascot
                    Image.asset(
                      'assets/images/panda.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Budget Blitz',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textDarkPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Instructions
                    const Text(
                      'Drag the expenses to the correct buckets\n(Needs, Wants, Savings) to score points.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: DesignTokens.textDarkPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        backgroundColor: const Color(0xFFFF6B9D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Score header
              _buildScoreHeader(),

              // Game area
              Expanded(
                child: Stack(
                  children: [
                    // Falling expenses
                    ..._fallingExpenses.map((fe) => _buildFallingExpenseWidget(fe)),

                    // Milestone popup
                    if (_showPopup)
                      Center(
                        child: _buildMilestonePopup(),
                      ),
                  ],
                ),
              ),

              // Buckets at the bottom
              _buildBuckets(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: DesignTokens.textDarkPrimary, size: 24),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _spawnTimer?.cancel();
              for (var expense in _fallingExpenses) {
                expense.controller.dispose();
              }
              context.pop();
            },
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Score',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: DesignTokens.textDarkSecondary,
                ),
              ),
              Text(
                '$_score',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textDarkPrimary,
                ),
              ),
            ],
          ),

          // Panda mascot
          Image.asset(
            'assets/images/panda.png',
            width: 60,
            height: 60,
          ),

          // Level
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Level',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: DesignTokens.textDarkSecondary,
                ),
              ),
              Text(
                '$_level',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textDarkPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallingExpenseWidget(FallingExpense fallingExpense) {
    return AnimatedBuilder(
      animation: fallingExpense.controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        // Use a constraint to limit chip width and center it properly
        return Positioned(
          left: 20,
          right: 20,
          top: MediaQuery.of(context).size.height * fallingExpense.controller.value * 0.6,
          child: Align(
            alignment: Alignment(
              // Convert 0.1-0.8 range to -1.0 to 1.0 range for Alignment
              (fallingExpense.startX - 0.45) * 2.2,
              0,
            ),
            child: child!,
          ),
        );
      },
      child: Draggable<FallingExpense>(
        data: fallingExpense,
        feedback: _buildExpenseChip(fallingExpense.expense, isDragging: true),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildExpenseChip(fallingExpense.expense),
        ),
        child: _buildExpenseChip(fallingExpense.expense),
      ),
    );
  }

  Widget _buildExpenseChip(Expense expense, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDragging
            ? const Color(0xFF0B0B0D).withValues(alpha: 0.9)
            : const Color(0xFF0B0B0D).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        expense.name,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBuckets() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: _buildBucket('Needs', ExpenseCategory.needs, const Color(0xFFFF6B6B))),
          const SizedBox(width: 12),
          Expanded(child: _buildBucket('Wants', ExpenseCategory.wants, const Color(0xFF63E6BE))),
          const SizedBox(width: 12),
          Expanded(child: _buildBucket('Savings', ExpenseCategory.savings, const Color(0xFF9775FA))),
        ],
      ),
    );
  }

  Widget _buildBucket(String label, ExpenseCategory category, Color color) {
    return DragTarget<FallingExpense>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        _onExpenseDropped(details.data, category);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isHovering ? 140 : 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: isHovering ? 24 : 16,
                spreadRadius: isHovering ? 4 : 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMilestonePopup() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF63E6BE), Color(0xFF748FFC)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
            ),
          ],
        ),
        child: Text(
          _currentPopupMessage,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEndScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textDarkPrimary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Score display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your Score',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: DesignTokens.textDarkSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.textDarkPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'High Score: $_highScore',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: DesignTokens.textDarkSecondary,
                            ),
                          ),
                          if (_xpEarned > 0 || _coinsEarned > 0) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      'XP Earned',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: DesignTokens.textDarkSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '+$_xpEarned',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF63E6BE),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 40),
                                Column(
                                  children: [
                                    const Text(
                                      'Coins Earned',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: DesignTokens.textDarkSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '+$_coinsEarned',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFD700),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Explanation
                    Text(
                      _gameOverReason,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: DesignTokens.textDarkPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _restartGame();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: const Color(0xFFFF6B9D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            'Restart',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FallingExpense {
  final Expense expense;
  final AnimationController controller;
  final double startX;

  FallingExpense({
    required this.expense,
    required this.controller,
    required this.startX,
  });
}
