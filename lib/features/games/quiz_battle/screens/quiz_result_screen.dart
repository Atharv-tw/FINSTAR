import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/supabase_functions_service.dart';
import '../models/quiz_question.dart';

class QuizResultScreen extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredAnswers;
  final int score;
  final int maxStreak;
  final List<AnswerOutcome> answerHistory;

  const QuizResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unansweredAnswers,
    required this.score,
    required this.maxStreak,
    required this.answerHistory,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final SupabaseFunctionsService _supabaseService = SupabaseFunctionsService();

  int _xpEarned = 0;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _saveResults();
  }

  Future<void> _saveResults() async {
    try {
      // Calculate time bonus (maxStreak can serve as a proxy for quick answers)
      final timeBonus = widget.maxStreak * 5;
      final isPerfect = widget.correctAnswers == widget.totalQuestions;

      final result = await _supabaseService.submitGameWithAchievements(
        gameType: 'quiz_battle',
        gameData: {
          'correctAnswers': widget.correctAnswers,
          'totalQuestions': widget.totalQuestions,
          'timeBonus': timeBonus,
          'isWinner': isPerfect, // Solo quiz - perfect score is a "win"
        },
      );

      if (result['success'] == true && mounted) {
        setState(() {
          _xpEarned = result['xpEarned'] ?? 0;
          _coinsEarned = result['coinsEarned'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error saving quiz results: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPerformanceGrade() {
    final percent = (widget.correctAnswers / widget.totalQuestions) * 100;
    if (percent == 100) return 'S';
    if (percent >= 90) return 'A+';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B+';
    if (percent >= 60) return 'B';
    if (percent >= 50) return 'C';
    return 'D';
  }

  String _getPerformanceMessage() {
    final percent = (widget.correctAnswers / widget.totalQuestions) * 100;
    if (percent == 100) return 'Perfect Score! You\'re a finance genius! 🏆';
    if (percent >= 90) return 'Excellent! You really know your stuff! 🌟';
    if (percent >= 80) return 'Great job! Solid financial knowledge! 👏';
    if (percent >= 70) return 'Good work! Keep learning and improving! 📚';
    if (percent >= 60) return 'Not bad! Review the topics you missed! 💪';
    if (percent >= 50) return 'You\'re getting there! Practice more! 📖';
    return 'Keep trying! Start with the basics! 🎯';
  }

  Color _getGradeColor() {
    final percent = (widget.correctAnswers / widget.totalQuestions) * 100;
    if (percent >= 80) return const Color(0xFF9BAD50);
    if (percent >= 60) return const Color(0xFFB6CFE4);
    return const Color(0xFFF2C1DE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFAE3),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildGradeCard(),
                      ),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildAnswerHistory(),
                        const SizedBox(height: 24),
                        _buildRewardsCard(),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildHeader() {

      const Color primaryColor = Color(0xFF9BAD50);

      const Color darkColor = Color(0xFF393027);

  

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: [darkColor, primaryColor],

          ),

        ),

        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Text(

              'Quiz Complete!',

              style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                  ),

            ),

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

              decoration: BoxDecoration(

                color: Colors.white.withAlpha(51),

                borderRadius: BorderRadius.circular(20),

              ),

              child: Row(

                children: [

                  Icon(Icons.stars, color: Colors.white, size: 16),

                  const SizedBox(width: 4),

                  Text(

                    '${widget.score} pts',

                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                        ),

                  ),

                ],

              ),

            ),

          ],

        ),

      );

    }

  

    Widget _buildGradeCard() {

      final grade = _getPerformanceGrade();

      final message = _getPerformanceMessage();

      final color = _getGradeColor();

      final darkColor = const Color(0xFF393027);

  

      return Container(

        padding: const EdgeInsets.all(32),

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: [color, color.withAlpha(204)],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

          ),

          borderRadius: BorderRadius.circular(24),

          boxShadow: [

            BoxShadow(

              color: color.withAlpha(77),

              blurRadius: 20,

              offset: const Offset(0, 10),

            ),

          ],

        ),

        child: Column(

          children: [

            Text(

              'Your Grade',

              style: Theme.of(context).textTheme.titleLarge?.copyWith(

                    color: darkColor.withAlpha(230),

                  ),

            ),

            const SizedBox(height: 16),

            Text(

              grade,

              style: Theme.of(context).textTheme.displayLarge?.copyWith(

                    color: darkColor,

                    fontWeight: FontWeight.bold,

                    fontSize: 100,

                  ),

            ),

            const SizedBox(height: 8),

            Text(

              '${widget.correctAnswers}/${widget.totalQuestions} Correct',

              style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                    color: darkColor.withAlpha(230),

                  ),

            ),

            const SizedBox(height: 16),

            Text(

              message,

              style: Theme.of(context).textTheme.bodyLarge?.copyWith(

                    color: darkColor,

                    height: 1.5,

                  ),

              textAlign: TextAlign.center,

            ),

          ],

        ),

      );

    }

  

    Widget _buildStatsGrid() {

      final accuracy = (widget.correctAnswers / widget.totalQuestions) * 100;

      const Color primaryColor = Color(0xFF9BAD50);

      const Color accentColor = Color(0xFFF2C1DE);

      const Color lightColor = Color(0xFFB6CFE4);

  

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: lightColor,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withAlpha(13),

              blurRadius: 10,

              offset: const Offset(0, 5),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Icon(Icons.bar_chart, color: primaryColor),

                const SizedBox(width: 8),

                Text(

                  'Performance Stats',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        fontWeight: FontWeight.bold,

                      ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            Row(

              children: [

                Expanded(

                  child: _buildStatCard(

                    icon: Icons.check_circle,

                    label: 'Correct',

                    value: '${widget.correctAnswers}',

                    color: primaryColor,

                  ),

                ),

                const SizedBox(width: 12),

                Expanded(

                  child: _buildStatCard(

                    icon: Icons.cancel,

                    label: 'Wrong',

                    value: '${widget.wrongAnswers}',

                    color: accentColor,

                  ),

                ),

              ],

            ),

            const SizedBox(height: 12),

            Row(

              children: [

                Expanded(

                  child: _buildStatCard(

                    icon: Icons.percent,

                    label: 'Accuracy',

                    value: '${accuracy.toStringAsFixed(0)}%',

                    color: primaryColor,

                  ),

                ),

                const SizedBox(width: 12),

                Expanded(

                  child: _buildStatCard(

                    icon: Icons.whatshot,

                    label: 'Max Streak',

                    value: '${widget.maxStreak}',

                    color: primaryColor,

                  ),

                ),

              ],

            ),

          ],

        ),

      );

    }

  

    Widget _buildStatCard({

      required IconData icon,

      required String label,

      required String value,

      required Color color,

    }) {

      return Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: color.withAlpha(26),

          borderRadius: BorderRadius.circular(16),

        ),

        child: Column(

          children: [

            Icon(icon, color: color, size: 32),

            const SizedBox(height: 8),

            Text(

              value,

              style: Theme.of(context).textTheme.headlineMedium?.copyWith(

                    color: color,

                    fontWeight: FontWeight.bold,

                  ),

            ),

            const SizedBox(height: 4),

            Text(

              label,

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                    color: const Color(0xFF393027),

                  ),

            ),

          ],

        ),

      );

    }

  

    Widget _buildAnswerHistory() {

      const Color primaryColor = Color(0xFF9BAD50);

      const Color accentColor = Color(0xFFF2C1DE);

      const Color lightColor = Color(0xFFB6CFE4);

  

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: lightColor,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withAlpha(13),

              blurRadius: 10,

              offset: const Offset(0, 5),

            ),

          ],

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Icon(Icons.history, color: primaryColor),

                const SizedBox(width: 8),

                Text(

                  'Answer Timeline',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        fontWeight: FontWeight.bold,

                      ),

                ),

              ],

            ),

            const SizedBox(height: 16),

            Wrap(

              spacing: 8,

              runSpacing: 8,

              children: List.generate(

                widget.answerHistory.length,

                (index) {

                  final isCorrect = widget.answerHistory[index];

                  return Container(

                    width: 40,

                    height: 40,

                    decoration: BoxDecoration(

                      color: isCorrect

                          ? primaryColor.withAlpha(26)

                          : accentColor.withAlpha(26),

                      border: Border.all(

                        color: isCorrect

                            ? primaryColor

                            : accentColor,

                        width: 2,

                      ),

                      borderRadius: BorderRadius.circular(8),

                    ),

                    child: Center(

                      child: Text(

                        '${index + 1}',

                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                              color: isCorrect

                                  ? primaryColor

                                  : accentColor,

                              fontWeight: FontWeight.bold,

                            ),

                      ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      );

    }

  

    Widget _buildRewardsCard() {

      final isPerfect = widget.correctAnswers == widget.totalQuestions;

      // Use server-returned values if available, otherwise use calculated fallback

      final coinsToShow = _coinsEarned > 0 ? _coinsEarned : (widget.score ~/ 10 + (isPerfect ? 50 : 0));

      final xpToShow = _xpEarned > 0 ? _xpEarned : (widget.score ~/ 5 + (isPerfect ? 100 : 0));

      const Color primaryColor = Color(0xFF9BAD50);

      const Color lightColor = Color(0xFFB6CFE4);

  

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: [

              primaryColor.withAlpha(51),

              lightColor.withAlpha(51),

            ],

          ),

          borderRadius: BorderRadius.circular(20),

          border: Border.all(

            color: primaryColor.withAlpha(128),

            width: 2,

          ),

        ),

        child: Column(

          children: [

            Row(

              children: [

                Icon(Icons.card_giftcard, color: primaryColor),

                const SizedBox(width: 8),

                Text(

                  'Rewards Earned',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        fontWeight: FontWeight.bold,

                      ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                _buildRewardItem(

                  icon: Icons.monetization_on,

                  label: 'Coins',

                  value: '+$coinsToShow',

                  color: primaryColor,

                ),

                Container(

                  width: 1,

                  height: 40,

                  color: const Color(0xFF393027).withAlpha(77),

                ),

                _buildRewardItem(

                  icon: Icons.stars,

                  label: 'XP',

                  value: '+$xpToShow',

                  color: primaryColor,

                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.skip_next,
                  label: 'Unanswered',
                  value: '${widget.unansweredAnswers}',
                  color: AppTheme.warningColor,
                ),

                child: Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Icon(Icons.emoji_events, color: primaryColor),

                    const SizedBox(width: 8),

                    Text(

                      'Perfect Score Bonus!',

                      style: Theme.of(context).textTheme.titleMedium?.copyWith(

                            color: primaryColor,

                            fontWeight: FontWeight.bold,

                          ),

                    ),

                  ],

                ),

              ),

            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.percent,
            label: 'Accuracy',
            value: '${accuracy.toStringAsFixed(0)}%',
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

          ],

        ),

      );

    }

    

    Widget _buildRewardItem({

      required IconData icon,

      required String label,

      required String value,

      required Color color,

    }) {

      return Column(

        children: [

          Icon(icon, color: color, size: 40),

          const SizedBox(height: 8),

          Text(

            value,

            style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                  color: color,

                  fontWeight: FontWeight.bold,

                ),

          ),

          Text(

            label,

            style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                  color: const Color(0xFF393027),

                ),

          ),

        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Answer Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              widget.answerHistory.length,
              (index) {
                final outcome = widget.answerHistory[index];
                final isCorrect = outcome == AnswerOutcome.correct;
                final isSkipped = outcome == AnswerOutcome.skipped;
                final isTimeout = outcome == AnswerOutcome.timeout;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : isSkipped
                            ? AppTheme.warningColor.withValues(alpha: 0.1)
                            : isTimeout
                                ? AppTheme.warningColor.withValues(alpha: 0.1)
                                : AppTheme.errorColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isCorrect
                          ? AppTheme.successColor
                          : isSkipped
                              ? AppTheme.warningColor
                              : isTimeout
                                  ? AppTheme.warningColor
                                  : AppTheme.errorColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isCorrect
                                ? AppTheme.successColor
                                : isSkipped
                                    ? AppTheme.warningColor
                                    : isTimeout
                                        ? AppTheme.warningColor
                                        : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,

                          ),

                    ),

                    const SizedBox(width: 8),

                    Icon(Icons.refresh, color: darkColor),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 12),

            SizedBox(

              width: double.infinity,

              height: 56,

              child: OutlinedButton(

                onPressed: () {

                  context.go('/');

                },

                style: OutlinedButton.styleFrom(

                  side: BorderSide(color: primaryColor),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(16),

                  ),

                ),

                child: Text(

                  'Back to Home',

                  style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        color: primaryColor,

                        fontWeight: FontWeight.bold,

                      ),

                ),

              ),

            ),

          ],

        ),

      );

    }

  }

  
