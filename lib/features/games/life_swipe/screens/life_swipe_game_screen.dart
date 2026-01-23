import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';
import '../models/spending_scenario.dart';

class LifeSwipeGameScreen extends StatefulWidget {
  const LifeSwipeGameScreen({super.key});

  @override
  State<LifeSwipeGameScreen> createState() => _LifeSwipeGameScreenState();
}

class _LifeSwipeGameScreenState extends State<LifeSwipeGameScreen>
    with TickerProviderStateMixin {
  List<SpendingScenario> scenarios = [];
  int currentIndex = 0;
  double dragDistance = 0;
  double dragAngle = 0;
  bool isDragging = false;
  bool hasStarted = false;
  bool showTutorial = true;

  // Game state
  int totalBudget = 20000;
  int incomeTotal = 20000; // Track income for overspending calculation
  int currentBudget = 20000;
  int savedMoney = 0;
  int spentMoney = 0;
  int happinessScore = 50;
  int disciplineScore = 50;
  int socialScore = 50;
  int futureScore = 50;
  double financialHealth = 100.0; // New: Financial health metric

  // Combo system
  int saveStreak = 0;
  int spendStreak = 0;
  int maxStreak = 0;
  List<String> badges = [];

  List<Map<String, dynamic>> decisions = [];

  // Visual feedback state
  String? scorePopup;
  Timer? _scorePopupTimer;
  bool lowBudgetWarning = false;

  late AnimationController _cardAnimationController;
  late AnimationController _budgetShakeController;
  late Animation<double> _budgetShakeAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _budgetShakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _budgetShakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _budgetShakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _budgetShakeController.dispose();
    _scorePopupTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      scenarios = SpendingScenario.getRandomScenarios(count: 20);
      hasStarted = true;
      currentIndex = 0;
      currentBudget = totalBudget;
      incomeTotal = totalBudget;
      savedMoney = 0;
      spentMoney = 0;
      happinessScore = 50;
      disciplineScore = 50;
      socialScore = 50;
      futureScore = 50;
      financialHealth = 100.0;
      saveStreak = 0;
      spendStreak = 0;
      maxStreak = 0;
      badges.clear();
      decisions.clear();
      lowBudgetWarning = false;
    });
  }

  void _showScorePopup(String message) {
    _scorePopupTimer?.cancel();
    setState(() {
      scorePopup = message;
    });

    _scorePopupTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          scorePopup = null;
        });
      }
    });
  }

  void _handleSwipe(bool swipedRight) {
    if (currentIndex >= scenarios.length) return;

    HapticFeedback.mediumImpact();

    final scenario = scenarios[currentIndex];
    final impact = swipedRight ? scenario.acceptImpact : scenario.declineImpact;

    // Update scores
    setState(() {
      if (swipedRight) {
        spentMoney += scenario.cost;
        currentBudget -= scenario.cost;
        spendStreak++;
        saveStreak = 0;

        // Check for low budget
        if (currentBudget < totalBudget * 0.25) {
          lowBudgetWarning = true;
          _budgetShakeController.forward(from: 0);
          HapticFeedback.heavyImpact();
        }
      } else {
        savedMoney += scenario.cost;
        saveStreak++;
        spendStreak = 0;

        // Award badge for discipline
        if (saveStreak == 5 && !badges.contains('disciplined')) {
          badges.add('disciplined');
          _showScorePopup('🏆 Disciplined Badge!');
        }
      }

      // Track max streak
      final currentStreak = swipedRight ? spendStreak : saveStreak;
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }

      // Combo bonus
      if (saveStreak >= 5) {
        disciplineScore = (disciplineScore + 10).clamp(0, 100);
        _showScorePopup('+10 Discipline Streak!');
      }

      // Update individual scores based on new impact schema
      happinessScore = (happinessScore + impact.happiness).clamp(0, 100);
      disciplineScore = (disciplineScore + impact.discipline).clamp(0, 100);
      socialScore = (socialScore + impact.socialLife).clamp(0, 100);
      futureScore = (futureScore + impact.investments).clamp(0, 100);

      // Calculate overspending penalty based on overspendFlag
      if (swipedRight && impact.overspendFlag) {
        // Apply financial health penalty for overspending with softer curve
        final overspendRatio = spentMoney / incomeTotal;
        if (overspendRatio > 1.0) {
          // Use power curve for smoother penalty, with floor at 30%
          final penalty = math.pow(overspendRatio - 1, 1.5).toDouble() * 40;
          financialHealth = (100 - penalty).clamp(30.0, 100.0);

          // Reduce all attributes due to money stress
          happinessScore = (happinessScore * 0.98).round().clamp(0, 100);
          disciplineScore = (disciplineScore * 0.97).round().clamp(0, 100);
          futureScore = (futureScore * 0.95).round().clamp(0, 100);

          // Additional penalty for Future and Discipline when overspending significantly
          if (overspendRatio > 1.1) {
            final futureReduction = ((overspendRatio - 1) * 20).round();
            futureScore = (futureScore - futureReduction).clamp(0, 100);
          }
          if (overspendRatio > 1.2) {
            final disciplineReduction = ((overspendRatio - 1.2) * 25).round();
            disciplineScore = (disciplineScore - disciplineReduction).clamp(0, 100);
          }
        }
      } else {
        // Recalculate financial health when not overspending
        final savingsRatio = currentBudget / totalBudget;
        financialHealth = (savingsRatio * 100).clamp(0, 100);
      }

      decisions.add({
        'scenario': scenario,
        'accepted': swipedRight,
        'budgetAfter': currentBudget,
      });
    });

    // Animate card away with spring physics
    _cardAnimationController.forward(from: 0).then((_) {
      setState(() {
        currentIndex++;
        dragDistance = 0;
        dragAngle = 0;
        _cardAnimationController.reset(); // Reset animation for next card

        if (currentIndex >= scenarios.length || currentBudget < 0) {
          _showResults();
        }
      });
    });
  }

  void _showResults() {
    // Use GoRouter's push with extra data
    context.push(
      '/game/life-swipe-result',
      extra: {
        'totalBudget': totalBudget,
        'remainingBudget': currentBudget,
        'spentMoney': spentMoney,
        'savedMoney': savedMoney,
        'happinessScore': happinessScore,
        'disciplineScore': disciplineScore,
        'socialScore': socialScore,
        'futureScore': futureScore,
        'financialHealth': financialHealth,
        'decisions': decisions,
        'badges': badges,
        'maxStreak': maxStreak,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasStarted
          ? null
          : AppBar(
              title: const Text('Life Swipe', style: TextStyle(color: const Color(0xFF393027))),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFB6CFE4).withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: hasStarted ? _buildGameScreen() : _buildInstructionsScreen(),
        ),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return Column(
      children: [

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget display with golden styling
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    const Color(0xFF9BAD50).withOpacity(0.3),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9BAD50).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '₹20,000',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: const Color(0xFF28301C),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Monthly Budget',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF28301C),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pocket money + internship earnings',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF28301C).withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildInstructionItem(
                  icon: Icons.trending_up,
                  title: 'Track Your Stats',
                  description: 'Every choice affects happiness, discipline, social life & future.',
                  color: const Color(0xFF9BAD50),
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  icon: Icons.star,
                  title: 'Earn Streaks & Badges',
                  description: 'Build saving streaks to unlock achievements!',
                  color: const Color(0xFFB6CFE4),
                ),
                const SizedBox(height: 32),

                // Warning box with modern design
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF393027).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/panda2.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These are REAL scenarios Indian teens face. Choose wisely!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF393027),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start button with gradient
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _startGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9BAD50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Swiping',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.swipe, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7), // Light background for item
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5), // Border color from item's color
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)], // Icon background gradient
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24), // Icon remains white
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF393027), // Dark text
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF28301C), // Slightly less dark text
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    if (currentIndex >= scenarios.length) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            _buildGameHeader(),
            _buildProgressBar(),
            _buildStatsRow(),
            Expanded(
              child: _buildCardStack(),
            ),
            _buildActionButtons(),
          ],
        ),

        // Score popup overlay
        if (scorePopup != null)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9BAD50).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        scorePopup!,
                        style: const TextStyle(
                          color: Color(0xFF393027),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameHeader() {
    return AnimatedBuilder(
      animation: _budgetShakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            lowBudgetWarning ? (_budgetShakeAnimation.value * (currentIndex % 2 == 0 ? 1 : -1)) : 0,
            0,
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF28301C).withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                        border: Border.all(
                          color: const Color(0xFF28301C).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          // Go back to play games screen
                          context.go('/game');
                        },
                      ),
                    ),
                    // Budget counter without rectangle
                    Column(
                      children: [
                        Text(
                          '₹${currentBudget.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: currentBudget < 5000
                                    ? const Color(0xFF393027)
                                    : const Color(0xFF9BAD50),
                              ),
                        ),
                        Text(
                          'Budget Left',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF28301C),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentIndex + 1}/${scenarios.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentIndex + 1) / scenarios.length;
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFB6CFE4).withOpacity(0.3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('😊', happinessScore),
          _buildStatChip('💪', disciplineScore),
          _buildStatChip('👥', socialScore),
          _buildStatChip('🎯', futureScore),
          if (saveStreak >= 3)
            _buildStreakChip('🔥', saveStreak),
        ],
      ),
    );
  }

  Widget _buildStatChip(String emoji, int score) {
    final color = score >= 70
        ? const Color(0xFF9BAD50)
        : score >= 40
            ? const Color(0xFFB6CFE4)
            : const Color(0xFF393027);

    final textColor = color == const Color(0xFF393027) ? const Color(0xFF9BAD50) : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakChip(String emoji, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            'x$streak',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Next card preview
            if (currentIndex + 1 < scenarios.length)
              Transform.scale(
                scale: 0.92,
                child: Opacity(
                  opacity: 0.5,
                  child: _buildCard(scenarios[currentIndex + 1], false),
                ),
              ),
            // Current card
            _buildDraggableCard(scenarios[currentIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableCard(SpendingScenario scenario) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          isDragging = true;
        });
        HapticFeedback.selectionClick();
      },
      onPanUpdate: (details) {
        setState(() {
          dragDistance += details.delta.dx;
          dragAngle = dragDistance / 1000;
        });

        // Light haptic feedback on threshold cross
        if (dragDistance.abs() > 100 && dragDistance.abs() < 105) {
          HapticFeedback.lightImpact();
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDragging = false;
          if (dragDistance.abs() > 120) {
            _handleSwipe(dragDistance > 0);
          } else {
            dragDistance = 0;
            dragAngle = 0;
          }
        });
      },
      child: AnimatedBuilder(
        animation: _cardAnimationController,
        builder: (context, child) {
          final animValue = _cardAnimationController.value;
          final flyOffDistance = dragDistance > 0 ? 500.0 : -500.0;

          return Transform.translate(
            offset: Offset(
              dragDistance + (animValue * flyOffDistance),
              animValue * -200,
            ),
            child: Transform.rotate(
              angle: dragAngle + (animValue * dragAngle * 2),
              child: Opacity(
                opacity: 1.0 - (animValue * 0.5),
                child: child,
              ),
            ),
          );
        },
        child: _buildCard(scenario, true),
      ),
    );
  }

  Widget _buildCard(SpendingScenario scenario, bool showOverlay) {
    final categoryColor = _getCategoryColor(scenario.category);

    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            categoryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: categoryColor.withOpacity(0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          if (dragDistance.abs() > 50)
            BoxShadow(
              color: (dragDistance > 0
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF63E6BE))
                  .withValues(alpha: 0.4),
              blurRadius: 40,
              spreadRadius: 5,
            ),
        ],
      ),
      child: Stack(
        children: [
          // Card content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getCategoryColor(scenario.category),
                            _getCategoryColor(scenario.category).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCategoryName(scenario.category),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      scenario.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scenario content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        scenario.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF393027),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        scenario.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF28301C),
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),

                // Cost with gradient background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFDC143C).withValues(alpha: 0.2),
                        const Color(0xFFDC143C).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFDC143C).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${scenario.cost.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: const Color(0xFFB22222), // Firebrick red - darker and bolder
                              fontWeight: FontWeight.w900, // Extra bold
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Swipe overlays with improved visuals
          if (showOverlay && dragDistance.abs() > 60)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (dragDistance > 0
                              ? const Color(0xFF9BAD50)
                              : const Color(0xFFB6CFE4))
                          .withOpacity(0.3),
                      (dragDistance > 0
                              ? const Color(0xFF9BAD50)
                              : const Color(0xFFB6CFE4))
                          .withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: dragDistance > 0 ? -0.3 : 0.3,
                    child: Transform.scale(
                      scale: 1.0 + (dragDistance.abs() / 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: dragDistance > 0
                                ? [const Color(0xFF9BAD50), const Color(0xFF393027)]
                                : [const Color(0xFFB6CFE4), const Color(0xFF28301C)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (dragDistance > 0
                                      ? const Color(0xFF9BAD50)
                                      : const Color(0xFFB6CFE4))
                                  .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          dragDistance > 0 ? 'SPEND' : 'SAVE',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Save button
          _buildActionButton(
            icon: Icons.close,
            gradient: const LinearGradient(
              colors: [Color(0xFFB6CFE4), Color(0xFF9BAD50)],
            ),
            onPressed: () => _handleSwipe(false),
          ),
          // Spend button
          _buildActionButton(
            icon: Icons.favorite,
            gradient: const LinearGradient(
              colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
            ),
            onPressed: () => _handleSwipe(true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(37.5),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ScenarioCategory category) {
    switch (category) {
      case ScenarioCategory.food:
        return const Color(0xFFFF6B6B);
      case ScenarioCategory.entertainment:
        return const Color(0xFF9B59B6);
      case ScenarioCategory.social:
        return const Color(0xFF3498DB);
      case ScenarioCategory.education:
        return const Color(0xFF5F8724);
      case ScenarioCategory.fashion:
        return const Color(0xFFE91E63);
      case ScenarioCategory.tech:
        return const Color(0xFF607D8B);
      case ScenarioCategory.transport:
        return const Color(0xFFF39C12);
      case ScenarioCategory.emergency:
        return const Color(0xFFE74C3C);
      case ScenarioCategory.health:
        return const Color(0xFF00BCD4);
      case ScenarioCategory.investment:
        return const Color(0xFF4CAF50);
    }
  }

  String _getCategoryName(ScenarioCategory category) {
    switch (category) {
      case ScenarioCategory.food:
        return 'Food & Dining';
      case ScenarioCategory.entertainment:
        return 'Entertainment';
      case ScenarioCategory.social:
        return 'Social';
      case ScenarioCategory.education:
        return 'Education';
      case ScenarioCategory.fashion:
        return 'Fashion';
      case ScenarioCategory.tech:
        return 'Tech';
      case ScenarioCategory.transport:
        return 'Transport';
      case ScenarioCategory.emergency:
        return 'Emergency';
      case ScenarioCategory.health:
        return 'Health';
      case ScenarioCategory.investment:
        return 'Investment';
    }
  }
}
