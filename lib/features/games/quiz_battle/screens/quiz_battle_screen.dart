import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_question.dart';
import '../../../../services/mascot_service.dart';
import '../../../../core/extensions.dart';

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
  int unansweredAnswers = 0;
  int streak = 0;
  int maxStreak = 0;
  List<AnswerOutcome> answerHistory = [];

  // Timer
  int timeLeft = 15; // seconds per question
  int _maxTimePerQuestion = 15;
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
  bool _timedOut = false;

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
      unansweredAnswers = 0;
      streak = 0;
      maxStreak = 0;
      answerHistory.clear();
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _maxTimePerQuestion = 15;
    timeLeft = _maxTimePerQuestion;
    _timerController.duration = Duration(seconds: _maxTimePerQuestion);
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
      _timedOut = true;
      hasAnswered = true;
      unansweredAnswers++;
      streak = 0;
      answerHistory.add(AnswerOutcome.timeout);
    });
    _shakeController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextQuestion();
    });
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

        answerHistory.add(AnswerOutcome.correct);
        _celebrationController.forward(from: 0);

      } else {
        wrongAnswers++;
        streak = 0;
        answerHistory.add(AnswerOutcome.wrong);
        _shakeController.forward(from: 0);

      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    final isLastQuestion = currentQuestionIndex + 1 >= questions.length;
    setState(() {
      currentQuestionIndex++;
      selectedAnswerIndex = null;
      hasAnswered = false;
      usedFiftyFifty = false;
      removedOptions.clear();
      _timedOut = false;
    });
    if (isLastQuestion) {
      _finishQuiz();
    } else {
      _startQuestionTimer();
    }
  }

  void _finishQuiz() {
    questionTimer?.cancel();
    if (!mounted) return;
    context.go(
      '/game/quiz-battle-result',
      extra: {
        'totalQuestions': questions.length,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'unansweredAnswers': unansweredAnswers,
        'score': score,
        'maxStreak': maxStreak,
        'answerHistory': answerHistory,
      },
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
      unansweredAnswers++;
      streak = 0;
      answerHistory.add(AnswerOutcome.skipped);
    });
    _nextQuestion();
  }

  void _useFreezeTime() {
    if (freezeTimeCount <= 0 || hasAnswered) return;

    setState(() {
      freezeTimeCount--;
      questionTimer?.cancel();

      // Add 10 seconds
      _maxTimePerQuestion += 10;
      timeLeft += 10;
      _timerController.duration = Duration(seconds: _maxTimePerQuestion);
      _timerController.value = 1 - (timeLeft / _maxTimePerQuestion);

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
          color: Color(0xFFFFFAE3),
        ),
        child: SafeArea(
          child: hasStarted ? _buildQuizScreen() : _buildInstructionsScreen(),
        ),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    const Color primaryColor = Color(0xFF9BAD50);
    const Color darkColor = Color(0xFF393027);
    const Color lightColor = Color(0xFFB6CFE4);
    const Color accentColor = Color(0xFFF2C1DE);
    return Column(
      children: [
        // Header - Blackened top strip with centered heading
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: darkColor.withValues(alpha: 217),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 51),
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: darkColor.withValues(alpha: 153),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 128),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 51),
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 64),
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.quiz, size: 60, color: primaryColor),
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
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Rules
                Text(
                  'How to Play',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                ),
                const SizedBox(height: 16),

                _buildRuleItem(
                  icon: Icons.timer,
                  title: 'Beat the Clock',
                  description: 'Answer before time runs out. Faster = more points!',
                  color: accentColor,
                  darkColor: darkColor,
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.whatshot,
                  title: 'Build Streaks',
                  description: 'Consecutive correct answers give bonus points.',
                  color: primaryColor,
                  darkColor: darkColor,
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.flash_on,
                  title: 'Use Power-Ups',
                  description: '50-50, Skip, Freeze Time - use them wisely!',
                  color: lightColor,
                  darkColor: darkColor,
                ),
                const SizedBox(height: 24),

                // Power-ups explanation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkColor.withValues(alpha: 153),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 51),
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
                          Icon(Icons.stars, color: primaryColor),
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
                backgroundColor: primaryColor,
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
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.play_arrow, color: darkColor, size: 28),
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
    required Color darkColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 51),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 102),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: darkColor, size: 24),
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
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: darkColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPowerUpInfo(String name, String description, int count) {
    const Color primaryColor = Color(0xFF9BAD50);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 51),            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                              color: primaryColor.withValues(alpha: 102),            ),
          ),
          child: Text(
            'x$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 217),
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
    const Color primaryColor = Color(0xFF9BAD50);
    const Color darkColor = Color(0xFF393027);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: darkColor.withValues(alpha: 217),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 51),
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
                      color: Colors.white.withValues(alpha: 179),
                    ),
              ),
              Text(
                '$score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),
            ],
          ),

          // Question counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 51),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withValues(alpha: 102),
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
                          ? primaryColor
                          : Colors.white.withValues(alpha: 128)),
                  const SizedBox(width: 4),
                  Text(
                    'Streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 179),
                        ),
                  ),
                ],
              ),
              Text(
                '$streak',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: streak > 0
                          ? primaryColor
                          : Colors.white.withValues(alpha: 128),
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
    const Color primaryColor = Color(0xFF9BAD50);
    const Color accentColor = Color(0xFFF2C1DE);

    Color timerColor;
    if (timeLeft > 10) {
      timerColor = primaryColor;
    } else if (timeLeft > 5) {
      timerColor = accentColor;
    } else {
      timerColor = Colors.red;
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
              colors: [timerColor, timerColor.withValues(alpha: 179)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    const Color darkColor = Color(0xFF393027);
    const Color lightColor = Color(0xFFB6CFE4);
    const Color primaryColor = Color(0xFF9BAD50);
    const Color accentColor = Color(0xFFF2C1DE);

    final bool isWrong = hasAnswered && selectedAnswerIndex != question.correctAnswerIndex;
    
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
          color: lightColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: darkColor.withValues(alpha: 26),
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
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getCategoryName(question.category),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: darkColor,
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
                    color: darkColor,
                  ),
            ),

            // Show explanation after answer
            if (hasAnswered) ...[
              const SizedBox(height: 16),
              if (_timedOut)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_off, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Time\'s up!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_timedOut) const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedAnswerIndex == question.correctAnswerIndex
                          ? primaryColor
                          : accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedAnswerIndex == question.correctAnswerIndex
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: selectedAnswerIndex == question.correctAnswerIndex
                          ? primaryColor
                          : darkColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: darkColor,
                            ),
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
    const Color primaryColor = Color(0xFF9BAD50);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPowerUpButton(
          icon: Icons.filter_2,
          label: '50-50',
          count: fiftyFiftyCount,
          onPressed: _useFiftyFifty,
          enabled: !hasAnswered && !usedFiftyFifty,
          activeColor: primaryColor,
        ),
        _buildPowerUpButton(
          icon: Icons.skip_next,
          label: 'Skip',
          count: skipCount,
          onPressed: _useSkip,
          enabled: !hasAnswered,
          activeColor: primaryColor,
        ),
        _buildPowerUpButton(
          icon: Icons.ac_unit,
          label: 'Freeze',
          count: freezeTimeCount,
          onPressed: _useFreezeTime,
          enabled: !hasAnswered,
          activeColor: primaryColor,
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
    required Color activeColor,
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
                ? activeColor.withValues(alpha: 26)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 77)
                  : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF393027) : Colors.grey,
                    ),
              ),
              Text(
                'x$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive ? activeColor : Colors.grey,
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

    const Color primaryColor = Color(0xFF9BAD50);
    const Color darkColor = Color(0xFF393027);
    const Color lightColor = Color(0xFFB6CFE4);
    const Color accentColor = Color(0xFFF2C1DE);

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color circleColor;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = primaryColor.withAlpha(51);
        borderColor = primaryColor;
        textColor = darkColor;
        circleColor = primaryColor;
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: 51);
        borderColor = Colors.red;
        textColor = darkColor;
        circleColor = Colors.red;
      } else {
        backgroundColor = Colors.grey[100]!;
        borderColor = Colors.grey[300]!;
        textColor = Colors.black54;
        circleColor = Colors.grey[400]!;
      }
    } else {
      backgroundColor = lightColor;
      borderColor = primaryColor.withAlpha(77);
      textColor = darkColor;
      circleColor = primaryColor;
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
                color: circleColor,
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
              Icon(Icons.check_circle, color: primaryColor),
            if (showResult && isSelected && !isCorrect)
              Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
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
