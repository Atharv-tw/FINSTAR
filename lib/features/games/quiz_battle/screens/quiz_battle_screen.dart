import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../core/design_tokens.dart';
import '../models/quiz_question.dart';
import 'quiz_result_screen.dart';
import '../../../../services/mascot_service.dart';

class QuizBattleScreen extends StatefulWidget {
  const QuizBattleScreen({super.key});

  @override
  State<QuizBattleScreen> createState() => _QuizBattleScreenState();
}

class _QuizBattleScreenState extends State<QuizBattleScreen>
    with TickerProviderStateMixin {
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  bool hasStarted = false;

  // Game state
  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int streak = 0;
  int maxStreak = 0;
  List<bool> answerHistory = [];

  // Timer
  int timeLeft = 15; // seconds per question
  Timer? questionTimer;
  late AnimationController _timerController;

  // Power-ups
  int fiftyFiftyCount = 2;
  int skipCount = 1;
  int freezeTimeCount = 1;
  bool usedFiftyFifty = false;
  List<int> removedOptions = [];

  // Animations
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    _timerController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      questions = QuizQuestion.getMixedDifficultyQuiz(count: 10);
      hasStarted = true;
      currentQuestionIndex = 0;
      score = 0;
      correctAnswers = 0;
      wrongAnswers = 0;
      streak = 0;
      maxStreak = 0;
      answerHistory.clear();
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    timeLeft = 15;
    _timerController.forward(from: 0);

    questionTimer?.cancel();
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _handleTimeout();
        }
      });
    });
  }

  void _handleTimeout() {
    questionTimer?.cancel();
    setState(() {
      hasAnswered = true;
      wrongAnswers++;
      streak = 0;
      answerHistory.add(false);
    });
    _shakeController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _handleAnswer(int selectedIndex) {
    if (hasAnswered) return;

    questionTimer?.cancel();
    setState(() {
      selectedAnswerIndex = selectedIndex;
      hasAnswered = true;

      final isCorrect =
          selectedIndex == questions[currentQuestionIndex].correctAnswerIndex;

      if (isCorrect) {
        correctAnswers++;
        streak++;
        if (streak > maxStreak) maxStreak = streak;

        // Calculate points with streak multiplier
        int points = questions[currentQuestionIndex].points;
        int streakBonus = (streak - 1) * 5; // +5 per streak
        int timeBonus = (timeLeft * 2).toInt(); // +2 per second left
        score += points + streakBonus + timeBonus;

        answerHistory.add(true);
        _celebrationController.forward(from: 0);

        // Show mascot celebration
        MascotService().showQuizFeedback(context, true);
      } else {
        wrongAnswers++;
        streak = 0;
        answerHistory.add(false);
        _shakeController.forward(from: 0);

        // Show mascot sad reaction
        MascotService().showQuizFeedback(context, false);
      }
    });

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    setState(() {
      currentQuestionIndex++;
      selectedAnswerIndex = null;
      hasAnswered = false;
      usedFiftyFifty = false;
      removedOptions.clear();

      if (currentQuestionIndex >= questions.length) {
        _finishQuiz();
      } else {
        _startQuestionTimer();
      }
    });
  }

  void _finishQuiz() {
    questionTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          totalQuestions: questions.length,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          score: score,
          maxStreak: maxStreak,
          answerHistory: answerHistory,
        ),
      ),
    );
  }

  // Power-ups
  void _useFiftyFifty() {
    if (fiftyFiftyCount <= 0 || hasAnswered || usedFiftyFifty) return;

    setState(() {
      fiftyFiftyCount--;
      usedFiftyFifty = true;

      final correctIndex = questions[currentQuestionIndex].correctAnswerIndex;
      final wrongOptions = List.generate(4, (i) => i)
          .where((i) => i != correctIndex)
          .toList();

      wrongOptions.shuffle();
      removedOptions = wrongOptions.take(2).toList();
    });
  }

  void _useSkip() {
    if (skipCount <= 0 || hasAnswered) return;

    setState(() {
      skipCount--;
      questionTimer?.cancel();
      answerHistory.add(false);
      _nextQuestion();
    });
  }

  void _useFreezeTime() {
    if (freezeTimeCount <= 0 || hasAnswered) return;

    setState(() {
      freezeTimeCount--;
      questionTimer?.cancel();

      // Add 10 seconds
      timeLeft += 10;

      // Restart timer
      questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            _handleTimeout();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          child: hasStarted ? _buildQuizScreen() : _buildInstructionsScreen(),
        ),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return Column(
      children: [
        // Header - Blackened top strip with centered heading
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0D).withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back button on left
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/'),
                ),
              ),
              const Spacer(),
              // Centered title
              Text(
                'Quiz Battle',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Invisible spacer for centering
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quiz format
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0D).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: DesignTokens.primaryStart.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: DesignTokens.primaryStart.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.quiz, size: 60, color: DesignTokens.primaryStart),
                      const SizedBox(height: 16),
                      Text(
                        '10 Questions',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '15 seconds per question',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Rules
                Text(
                  'How to Play',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),

                _buildRuleItem(
                  icon: Icons.timer,
                  title: 'Beat the Clock',
                  description: 'Answer before time runs out. Faster = more points!',
                  color: AppTheme.warningColor,
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.whatshot,
                  title: 'Build Streaks',
                  description: 'Consecutive correct answers give bonus points.',
                  color: AppTheme.accentYellow,
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.flash_on,
                  title: 'Use Power-Ups',
                  description: '50-50, Skip, Freeze Time - use them wisely!',
                  color: AppTheme.successColor,
                ),
                const SizedBox(height: 24),

                // Power-ups explanation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0D).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars, color: AppTheme.accentYellow),
                          const SizedBox(width: 8),
                          Text(
                            'Power-Ups Available',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPowerUpInfo('50-50', 'Remove 2 wrong answers', 2),
                      const SizedBox(height: 8),
                      _buildPowerUpInfo('Skip', 'Skip difficult question', 1),
                      const SizedBox(height: 8),
                      _buildPowerUpInfo('Freeze', 'Add 10 extra seconds', 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start button
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Quiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: color, size: 24),
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
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPowerUpInfo(String name, String description, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accentYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.accentYellow.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            'x$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$name: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                TextSpan(
                  text: description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizScreen() {
    if (currentQuestionIndex >= questions.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = questions[currentQuestionIndex];

    return Column(
      children: [
        _buildQuizHeader(),
        _buildTimerBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildQuestionCard(question),
                const SizedBox(height: 24),
                _buildPowerUps(),
                const SizedBox(height: 24),
                _buildAnswerOptions(question),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D).withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                '$score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.primaryStart,
                    ),
              ),
            ],
          ),

          // Question counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: DesignTokens.primaryStart.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DesignTokens.primaryStart.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '${currentQuestionIndex + 1}/${questions.length}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),

          // Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.whatshot,
                      size: 16,
                      color: streak > 0
                          ? AppTheme.accentYellow
                          : Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
              Text(
                '$streak',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: streak > 0
                          ? AppTheme.accentYellow
                          : Colors.white.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    final progress = timeLeft / 15;
    Color timerColor;
    if (timeLeft > 10) {
      timerColor = AppTheme.successColor;
    } else if (timeLeft > 5) {
      timerColor = AppTheme.warningColor;
    } else {
      timerColor = AppTheme.errorColor;
    }

    return Container(
      height: 6,
      color: Colors.grey[200],
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [timerColor, timerColor.withValues(alpha: 0.7)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(question.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getCategoryName(question.category),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getCategoryColor(question.category),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 20),

            // Question
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
            ),

            // Show explanation after answer
            if (hasAnswered) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (selectedAnswerIndex == question.correctAnswerIndex
                          ? AppTheme.successColor
                          : AppTheme.errorColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedAnswerIndex == question.correctAnswerIndex
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: selectedAnswerIndex == question.correctAnswerIndex
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPowerUpButton(
          icon: Icons.filter_2,
          label: '50-50',
          count: fiftyFiftyCount,
          onPressed: _useFiftyFifty,
          enabled: !hasAnswered && !usedFiftyFifty,
        ),
        _buildPowerUpButton(
          icon: Icons.skip_next,
          label: 'Skip',
          count: skipCount,
          onPressed: _useSkip,
          enabled: !hasAnswered,
        ),
        _buildPowerUpButton(
          icon: Icons.ac_unit,
          label: 'Freeze',
          count: freezeTimeCount,
          onPressed: _useFreezeTime,
          enabled: !hasAnswered,
        ),
      ],
    );
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    final isActive = count > 0 && enabled;

    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: InkWell(
        onTap: isActive ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentYellow.withValues(alpha: 0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppTheme.accentYellow.withValues(alpha: 0.3)
                  : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.accentYellow : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.textPrimary : Colors.grey,
                    ),
              ),
              Text(
                'x$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive ? AppTheme.accentYellow : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    return Column(
      children: List.generate(
        question.options.length,
        (index) {
          final isRemoved = removedOptions.contains(index);
          if (isRemoved) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAnswerOption(question, index),
          );
        },
      ),
    );
  }

  Widget _buildAnswerOption(QuizQuestion question, int index) {
    final isSelected = selectedAnswerIndex == index;
    final isCorrect = index == question.correctAnswerIndex;
    final showResult = hasAnswered;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.1);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
      } else if (isSelected) {
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.1);
        borderColor = AppTheme.errorColor;
        textColor = AppTheme.errorColor;
      } else {
        backgroundColor = Colors.grey[100]!;
        borderColor = Colors.grey[300]!;
        textColor = AppTheme.textSecondary;
      }
    } else {
      backgroundColor = Colors.white;
      borderColor = AppTheme.primaryColor.withValues(alpha: 0.3);
      textColor = AppTheme.textPrimary;
    }

    return InkWell(
      onTap: hasAnswered ? null : () => _handleAnswer(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: showResult && isCorrect
                    ? AppTheme.successColor
                    : (showResult && isSelected
                        ? AppTheme.errorColor
                        : borderColor),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                question.options[index],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            if (showResult && isCorrect)
              Icon(Icons.check_circle, color: AppTheme.successColor),
            if (showResult && isSelected && !isCorrect)
              Icon(Icons.cancel, color: AppTheme.errorColor),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(QuizCategory category) {
    switch (category) {
      case QuizCategory.budgeting:
        return const Color(0xFF3498DB);
      case QuizCategory.saving:
        return const Color(0xFF2ECC71);
      case QuizCategory.investing:
        return const Color(0xFF9B59B6);
      case QuizCategory.banking:
        return const Color(0xFF1ABC9C);
      case QuizCategory.taxes:
        return const Color(0xFFE74C3C);
      case QuizCategory.credit:
        return const Color(0xFFE67E22);
      case QuizCategory.insurance:
        return const Color(0xFFF39C12);
      case QuizCategory.general:
        return const Color(0xFF34495E);
    }
  }

  String _getCategoryName(QuizCategory category) {
    switch (category) {
      case QuizCategory.budgeting:
        return 'Budgeting';
      case QuizCategory.saving:
        return 'Saving';
      case QuizCategory.investing:
        return 'Investing';
      case QuizCategory.banking:
        return 'Banking';
      case QuizCategory.taxes:
        return 'Taxes';
      case QuizCategory.credit:
        return 'Credit & Loans';
      case QuizCategory.insurance:
        return 'Insurance';
      case QuizCategory.general:
        return 'General Finance';
    }
  }
}
