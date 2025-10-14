import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../core/design_tokens.dart';
import '../../../../services/local_storage_service.dart';
import '../models/spending_scenario.dart';

class LifeSwipeResultScreen extends StatefulWidget {
  final int totalBudget;
  final int remainingBudget;
  final int spentMoney;
  final int savedMoney;
  final int happinessScore;
  final int disciplineScore;
  final int socialScore;
  final int futureScore;
  final double financialHealth;
  final List<Map<String, dynamic>> decisions;
  final List<String>? badges; // Badges earned during gameplay
  final int? maxStreak; // Maximum save streak achieved

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
    required this.financialHealth,
    required this.decisions,
    this.badges,
    this.maxStreak,
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
    // New weighted scoring formula:
    // Happiness: 25%, Investments (Future): 35%, Social Life: 15%, Discipline: 25%
    final baseScore = (widget.happinessScore * 0.25) +
                      (widget.futureScore * 0.35) +
                      (widget.socialScore * 0.15) +
                      (widget.disciplineScore * 0.25);

    // Apply Financial Health as a 30% modifier, not a destroyer
    // 70% comes from performance metrics, 30% from financial health
    final finalScore = (baseScore * 0.7) + (baseScore * (widget.financialHealth / 100) * 0.3);

    return finalScore.clamp(0, 100).toInt();
  }

  int _calculateBudgetScore() {
    final remainingBudget = widget.remainingBudget;
    final totalBudget = widget.totalBudget;

    // If over budget (negative remaining), severe penalty
    if (remainingBudget < 0) {
      final overBudgetPercent = (remainingBudget.abs() / totalBudget);
      if (overBudgetPercent >= 0.5) return 0; // 50%+ over budget = 0 points
      if (overBudgetPercent >= 0.3) return 10; // 30-50% over = 10 points
      if (overBudgetPercent >= 0.1) return 25; // 10-30% over = 25 points
      return 40; // <10% over = 40 points
    }

    // Calculate savings rate (remaining / total)
    final savingsRate = remainingBudget / totalBudget;

    // Score based on savings rate
    if (savingsRate >= 0.70) return 100; // Saved 70%+ = Perfect
    if (savingsRate >= 0.60) return 95;  // Saved 60-70% = Excellent
    if (savingsRate >= 0.50) return 90;  // Saved 50-60% = Great
    if (savingsRate >= 0.40) return 80;  // Saved 40-50% = Very Good
    if (savingsRate >= 0.30) return 70;  // Saved 30-40% = Good
    if (savingsRate >= 0.20) return 60;  // Saved 20-30% = Decent
    if (savingsRate >= 0.10) return 50;  // Saved 10-20% = Average
    if (savingsRate >= 0.05) return 40;  // Saved 5-10% = Below Average
    return 30; // Saved <5% = Poor
  }

  String _getPerformanceGrade() {
    final score = _calculateOverallScore();
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 75) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 65) return 'B-';
    if (score >= 60) return 'C+';
    if (score >= 55) return 'C';
    if (score >= 50) return 'C-';
    if (score >= 45) return 'D+';
    if (score >= 40) return 'D';
    return 'F';
  }

  String _getPerformanceMessage() {
    final score = _calculateOverallScore();
    final isOverBudget = widget.remainingBudget < 0;

    if (isOverBudget) {
      final overAmount = widget.remainingBudget.abs();
      return 'Went ₹$overAmount over budget! You need to control spending better.';
    }

    // New evaluation bands
    if (score >= 80) return 'Balanced & Future-Ready! You\'ve mastered life and money.';
    if (score >= 60) return 'Doing Well, Needs Consistency. Keep up the good work!';
    if (score >= 40) return 'Unstable – Rethink Spending. Focus on long-term goals.';
    return 'Financially At Risk. Major changes needed in your approach.';
  }

  Color _getGradeColor() {
    final score = _calculateOverallScore();
    if (score >= 70) return AppTheme.successColor;
    if (score >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Widget _buildFinancialHealthCard() {
    final healthColor = widget.financialHealth >= 80
        ? AppTheme.successColor
        : widget.financialHealth >= 50
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    final healthStatus = widget.financialHealth >= 80
        ? 'Excellent'
        : widget.financialHealth >= 50
            ? 'Moderate'
            : 'At Risk';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: healthColor),
              const SizedBox(width: 8),
              Text(
                'Financial Health',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.financialHealth.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: healthColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    healthStatus,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: healthColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: healthColor.withValues(alpha: 0.3),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.financialHealth >= 80
                        ? '😊'
                        : widget.financialHealth >= 50
                            ? '😐'
                            : '😰',
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.financialHealth >= 100
                  ? 'Perfect! You stayed within budget and made smart choices.'
                  : widget.financialHealth >= 80
                      ? 'Great job managing your spending!'
                      : widget.financialHealth >= 50
                          ? 'Overspending detected. Money stress is affecting your life.'
                          : 'Severe overspending! This is impacting all areas of your life.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          top: false,
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
                      _buildFinancialHealthCard(),
                      const SizedBox(height: 24),
                      if ((widget.badges?.isNotEmpty ?? false) || (widget.maxStreak ?? 0) > 0)
                        _buildAchievements(),
                      if ((widget.badges?.isNotEmpty ?? false) || (widget.maxStreak ?? 0) > 0)
                        const SizedBox(height: 24),
                      _buildInsights(),
                      const SizedBox(height: 24),
                      _buildDecisionHistory(),
                      const SizedBox(height: 24),
                      _buildCategoryBreakdown(),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.black,
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
    final savingsRate = (widget.remainingBudget / widget.totalBudget);
    final spendRate = (widget.spentMoney / widget.totalBudget);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Three summary boxes stacked vertically
          _buildSummaryBox(
            label: 'Total',
            value: '₹${widget.totalBudget}',
            icon: Icons.wallet,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          _buildSummaryBox(
            label: 'Spent',
            value: '₹${widget.spentMoney}',
            icon: Icons.trending_down,
            color: AppTheme.errorColor,
            percentage: '${(spendRate * 100).toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 12),
          _buildSummaryBox(
            label: 'Saved',
            value: '₹${widget.remainingBudget}',
            icon: Icons.trending_up,
            color: AppTheme.successColor,
            percentage: '${(savingsRate * 100).toStringAsFixed(0)}%',
          ),

          const SizedBox(height: 20),

          // Savings rate progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savings Rate',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                  ),
                  Text(
                    '${(savingsRate * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: savingsRate >= 0.5
                              ? AppTheme.successColor
                              : savingsRate >= 0.3
                                  ? AppTheme.warningColor
                                  : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: savingsRate.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: savingsRate >= 0.5
                            ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                            : savingsRate >= 0.3
                                ? [const Color(0xFFF59E0B), const Color(0xFFEA580C)]
                                : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (savingsRate >= 0.5
                                  ? AppTheme.successColor
                                  : savingsRate >= 0.3
                                      ? AppTheme.warningColor
                                      : AppTheme.errorColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                savingsRate >= 0.6
                    ? '🎯 Excellent! You\'re a super saver!'
                    : savingsRate >= 0.4
                        ? '👍 Good job! Keep it up!'
                        : savingsRate >= 0.2
                            ? '⚠️ Try to save more next time'
                            : '🚨 You need to control spending',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    if (percentage != null)
                      Text(
                        percentage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                  ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                      color: const Color(0xFF1A1A1A),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: score / 100,
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final insights = _generateInsights();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          insight['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
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
                                  color: const Color(0xFF1A1A1A),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight['message'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF4A4A4A),
                                  height: 1.4,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                      color: const Color(0xFF1A1A1A),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
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
                  color: const Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDonutChart() {
    final spentPercent = (widget.spentMoney / widget.totalBudget * 100);
    final savedPercent = (widget.savedMoney / widget.totalBudget * 100);
    final remainingPercent = (widget.remainingBudget / widget.totalBudget * 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor.withValues(alpha: 0.2), AppTheme.primaryColor.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.donut_large, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Budget Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Enhanced donut chart with better center display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 240,
                width: 240,
                child: CustomPaint(
                  painter: EnhancedDonutChartPainter(
                    spentAmount: widget.spentMoney.toDouble(),
                    savedAmount: widget.savedMoney.toDouble(),
                    remainingAmount: widget.remainingBudget.toDouble(),
                  ),
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${widget.totalBudget}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total Budget',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Modern legend with cards
          Column(
            children: [
              _buildModernLegendItem(
                icon: Icons.shopping_cart,
                label: 'Spent',
                amount: '₹${widget.spentMoney}',
                percentage: '${spentPercent.toStringAsFixed(1)}%',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 12),
              _buildModernLegendItem(
                icon: Icons.savings,
                label: 'Saved',
                amount: '₹${widget.savedMoney}',
                percentage: '${savedPercent.toStringAsFixed(1)}%',
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 12),
              _buildModernLegendItem(
                icon: Icons.account_balance_wallet,
                label: 'Remaining',
                amount: '₹${widget.remainingBudget}',
                percentage: '${remainingPercent.toStringAsFixed(1)}%',
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernLegendItem({
    required IconData icon,
    required String label,
    required String amount,
    required String percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        percentage,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E40AF).withValues(alpha: 0.55), // Translucent darker blue
            const Color(0xFF1E3A8A).withValues(alpha: 0.45), // Slightly darker translucent blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFBBF24), // Golden yellow border
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Achievements Unlocked',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.maxStreak != null && widget.maxStreak! > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF374151).withValues(alpha: 0.8), // Medium gray
                    const Color(0xFF1F2937).withValues(alpha: 0.6), // Dark gray
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Best Save Streak',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.maxStreak} saves in a row!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFE5E7EB),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (widget.badges != null && widget.badges!.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.badges!.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF374151).withValues(alpha: 0.7),
                        const Color(0xFF1F2937).withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getBadgeEmoji(badge),
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _getBadgeTitle(badge),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getBadgeEmoji(String badge) {
    switch (badge) {
      case 'disciplined':
        return '🎯';
      case 'socialite':
        return '🎉';
      case 'investor':
        return '📈';
      case 'balanced':
        return '⚖️';
      default:
        return '🏅';
    }
  }

  String _getBadgeTitle(String badge) {
    switch (badge) {
      case 'disciplined':
        return 'Disciplined Saver';
      case 'socialite':
        return 'Social Butterfly';
      case 'investor':
        return 'Future Investor';
      case 'balanced':
        return 'Life Balance Master';
      default:
        return 'Achievement';
    }
  }

  Widget _buildCategoryBreakdown() {
    // Analyze decisions by category
    final Map<String, int> categorySpending = {};
    final Map<String, int> categorySavings = {};

    for (final decision in widget.decisions) {
      final scenario = decision['scenario'] as SpendingScenario;
      final category = scenario.category.toString().split('.').last; // Extract enum name
      final cost = scenario.cost;
      final accepted = decision['accepted'] as bool;

      if (accepted) {
        categorySpending[category] = (categorySpending[category] ?? 0) + cost;
      } else {
        categorySavings[category] = (categorySavings[category] ?? 0) + cost;
      }
    }

    // Get top 3 spending categories
    final sortedSpending = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSpending = sortedSpending.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Top Spending Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (topSpending.isEmpty)
            Text(
              'No spending recorded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            )
          else
            ...topSpending.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final categoryData = entry.value;
              final categoryColor = _getCategoryColor(categoryData.key);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.08),
                      categoryColor.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCategoryName(categoryData.key),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${categoryData.value}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getCategoryEmoji(categoryData.key),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF6B6B);
      case 'entertainment':
        return const Color(0xFF4ECDC4);
      case 'social':
        return const Color(0xFFFFE66D);
      case 'education':
        return const Color(0xFF95E1D3);
      case 'fashion':
        return const Color(0xFFF38181);
      case 'tech':
        return const Color(0xFFAA96DA);
      case 'transport':
        return const Color(0xFF6BCF9E);
      case 'emergency':
        return const Color(0xFFFFB347);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'Food & Dining';
      case 'entertainment':
        return 'Entertainment';
      case 'social':
        return 'Social Life';
      case 'education':
        return 'Education';
      case 'fashion':
        return 'Fashion';
      case 'tech':
        return 'Tech & Gadgets';
      case 'transport':
        return 'Transportation';
      case 'emergency':
        return 'Emergency';
      default:
        return category;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'entertainment':
        return '🎮';
      case 'social':
        return '👥';
      case 'education':
        return '📚';
      case 'fashion':
        return '👕';
      case 'tech':
        return '💻';
      case 'transport':
        return '🚗';
      case 'emergency':
        return '🚨';
      default:
        return '📦';
    }
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
                HapticFeedback.mediumImpact();
                context.push('/game/life-swipe');
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
                HapticFeedback.mediumImpact();
                context.go('/game');
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

// Enhanced custom painter for donut chart with modern styling
class EnhancedDonutChartPainter extends CustomPainter {
  final double spentAmount;
  final double savedAmount;
  final double remainingAmount;

  EnhancedDonutChartPainter({
    required this.spentAmount,
    required this.savedAmount,
    required this.remainingAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 36.0; // Thicker stroke for modern look
    final innerRadius = radius - strokeWidth;

    final total = spentAmount + savedAmount + remainingAmount;
    if (total == 0) return;

    // Calculate angles
    final spentAngle = (spentAmount / total) * 2 * math.pi;
    final savedAngle = (savedAmount / total) * 2 * math.pi;
    final remainingAngle = (remainingAmount / total) * 2 * math.pi;

    // Draw background circle (lighter version)
    final bgPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - (strokeWidth / 2), bgPaint);

    // Draw spent arc with gradient effect
    final spentPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
      -math.pi / 2,
      spentAngle,
      false,
      spentPaint,
    );

    // Draw saved arc with gradient effect
    final savedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
      -math.pi / 2 + spentAngle,
      savedAngle,
      false,
      savedPaint,
    );

    // Draw remaining arc with gradient effect
    final remainingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
      -math.pi / 2 + spentAngle + savedAngle,
      remainingAngle,
      false,
      remainingPaint,
    );

    // Add subtle inner shadow effect
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, innerRadius, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
