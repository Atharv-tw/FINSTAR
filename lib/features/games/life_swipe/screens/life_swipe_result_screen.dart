import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../services/local_storage_service.dart';

class LifeSwipeResultScreen extends StatefulWidget {
  final int totalBudget;
  final int remainingBudget;
  final int spentMoney;
  final int savedMoney;
  final int happinessScore;
  final int disciplineScore;
  final int socialScore;
  final int futureScore;
  final List<Map<String, dynamic>> decisions;

  const LifeSwipeResultScreen({
    super.key,
    required this.totalBudget,
    required this.remainingBudget,
    required this.spentMoney,
    required this.savedMoney,
    required this.happinessScore,
    required this.disciplineScore,
    required this.socialScore,
    required this.futureScore,
    required this.decisions,
  });

  @override
  State<LifeSwipeResultScreen> createState() => _LifeSwipeResultScreenState();
}

class _LifeSwipeResultScreenState extends State<LifeSwipeResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _saveResults();
  }

  Future<void> _saveResults() async {
    final storage = await LocalStorageService.getInstance();
    final overallScore = _calculateOverallScore();

    // Award coins and XP
    final coinsEarned = (overallScore * 2).toInt();
    final xpEarned = (overallScore * 5).toInt();

    await storage.addReward(coins: coinsEarned, xp: xpEarned);
  }

  int _calculateOverallScore() {
    final avgScore = (widget.happinessScore +
                     widget.disciplineScore +
                     widget.socialScore +
                     widget.futureScore) / 4;
    return avgScore.toInt();
  }

  String _getPerformanceGrade() {
    final score = _calculateOverallScore();
    if (score >= 80) return 'A+';
    if (score >= 70) return 'A';
    if (score >= 60) return 'B+';
    if (score >= 50) return 'B';
    if (score >= 40) return 'C';
    return 'D';
  }

  String _getPerformanceMessage() {
    final score = _calculateOverallScore();
    if (score >= 80) return 'Financial Genius! You balanced everything perfectly.';
    if (score >= 70) return 'Smart Money Moves! You made mostly good choices.';
    if (score >= 60) return 'Decent Job! Room for improvement in some areas.';
    if (score >= 50) return 'Average Performance. Consider long-term impacts.';
    if (score >= 40) return 'Needs Work. Too many impulse decisions.';
    return 'Risky Choices! Focus on building discipline.';
  }

  Color _getGradeColor() {
    final score = _calculateOverallScore();
    if (score >= 70) return AppTheme.successColor;
    if (score >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGradeCard(),
                      const SizedBox(height: 24),
                      _buildFinancialSummary(),
                      const SizedBox(height: 24),
                      _buildScoreBreakdown(),
                      const SizedBox(height: 24),
                      _buildInsights(),
                      const SizedBox(height: 24),
                      _buildDecisionHistory(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Monthly Report',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Game Over',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Grade',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            grade,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 80,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_calculateOverallScore()}/100',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Financial Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Starting Budget',
            '₹${widget.totalBudget}',
            Colors.grey[600]!,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total Spent',
            '- ₹${widget.spentMoney}',
            AppTheme.errorColor,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Total Saved',
            '+ ₹${widget.savedMoney}',
            AppTheme.successColor,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Remaining Budget',
            '₹${widget.remainingBudget}',
            widget.remainingBudget > widget.totalBudget * 0.5
                ? AppTheme.successColor
                : AppTheme.warningColor,
            isLarge: true,
          ),
          const SizedBox(height: 16),
          // Savings rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings Rate',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${((widget.remainingBudget / widget.totalBudget) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.successColor,
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

  Widget _buildSummaryRow(String label, String value, Color color,
      {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: isLarge
              ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }

  Widget _buildScoreBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.trending_up, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildScoreBar('Happiness', widget.happinessScore, AppTheme.accentYellow),
          const SizedBox(height: 16),
          _buildScoreBar('Discipline', widget.disciplineScore, AppTheme.successColor),
          const SizedBox(height: 16),
          _buildScoreBar('Social Life', widget.socialScore, AppTheme.primaryColor),
          const SizedBox(height: 16),
          _buildScoreBar('Future Planning', widget.futureScore, AppTheme.secondaryColor),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '$score/100',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final insights = _generateInsights();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.lightbulb, color: AppTheme.accentYellow),
              const SizedBox(width: 8),
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['icon'] as String,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['title'] as String,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight['message'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<Map<String, String>> _generateInsights() {
    final insights = <Map<String, String>>[];

    // Discipline insight
    if (widget.disciplineScore >= 70) {
      insights.add({
        'icon': '💪',
        'title': 'Strong Willpower',
        'message': 'You resisted many temptations. This discipline will pay off long-term!',
      });
    } else if (widget.disciplineScore < 40) {
      insights.add({
        'icon': '⚠️',
        'title': 'Impulse Control Needed',
        'message': 'Too many instant gratification choices. Try the 24-hour rule before buying.',
      });
    }

    // Budget insight
    final savingsRate = (widget.remainingBudget / widget.totalBudget);
    if (savingsRate > 0.6) {
      insights.add({
        'icon': '🎯',
        'title': 'Excellent Saver',
        'message': 'You saved ${(savingsRate * 100).toStringAsFixed(0)}% of your budget! Great financial discipline.',
      });
    } else if (savingsRate < 0.2) {
      insights.add({
        'icon': '🚨',
        'title': 'Budget Alert',
        'message': 'You spent ${((1 - savingsRate) * 100).toStringAsFixed(0)}% of your money. Consider the 50/30/20 rule.',
      });
    }

    // Social insight
    if (widget.socialScore < 40) {
      insights.add({
        'icon': '👥',
        'title': 'Balance Social Life',
        'message': 'Don\'t sacrifice relationships entirely. Some experiences are worth the cost.',
      });
    }

    // Future planning
    if (widget.futureScore >= 70) {
      insights.add({
        'icon': '🚀',
        'title': 'Future-Focused',
        'message': 'You invested in your future wisely. These choices compound over time.',
      });
    }

    return insights;
  }

  Widget _buildDecisionHistory() {
    final spendDecisions = widget.decisions.where((d) => d['accepted'] == true).length;
    final saveDecisions = widget.decisions.length - spendDecisions;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.history, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Decision Breakdown',
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
                child: _buildDecisionStat(
                  'Spent',
                  spendDecisions,
                  AppTheme.errorColor,
                  Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDecisionStat(
                  'Saved',
                  saveDecisions,
                  AppTheme.successColor,
                  Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionStat(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.go('/game/life-swipe');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Play Again',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                side: BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Back to Home',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
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
