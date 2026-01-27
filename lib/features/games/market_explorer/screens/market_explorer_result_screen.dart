import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';

import '../models/market_explorer_models.dart';
import '../../../../services/supabase_functions_service.dart';

class MarketExplorerResultScreen extends StatefulWidget {
  final SimulationResult result;

  const MarketExplorerResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<MarketExplorerResultScreen> createState() =>
      _MarketExplorerResultScreenState();
}

class _MarketExplorerResultScreenState
    extends State<MarketExplorerResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final SupabaseFunctionsService _supabaseService = SupabaseFunctionsService();

  int _xpEarned = 0;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Auto-claim rewards
    _claimRewards();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _claimRewards() async {
    try {
      final portfolio = widget.result.portfolio;

      // Build portfolio data for submission
      final portfolioData = <String, double>{};
      for (var asset in portfolio.assets.values) {
        portfolioData[asset.type.name] = asset.currentValue;
      }
      portfolioData['cash'] = portfolio.unallocatedAmount;

      final result = await _supabaseService.submitGameWithAchievements(
        gameType: 'market_explorer',
        gameData: {
          'portfolioValue': portfolio.totalValue,
          'initialValue': portfolio.totalCapital,
          'portfolio': portfolioData,
          'decisionsCount': portfolio.eventsOccurred.length,
        },
      );

      if (result['success'] == true && mounted) {
        setState(() {
          _xpEarned = result['xpEarned'] ?? widget.result.xpEarned;
          _coinsEarned = result['coinsEarned'] ?? widget.result.coinsEarned;
        });
      }
    } catch (e) {
      debugPrint('Error claiming rewards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(color: Color(0xFF393027))),
        backgroundColor: const Color(0xFFFFFAE3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF393027)),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        color: const Color(0xFFFFFAE3),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Performance Rating
                  _buildPerformanceCard(),
                  const SizedBox(height: 24),

                  // Score Breakdown
                  _buildScoreCard(),
                  const SizedBox(height: 24),

                  // Portfolio Summary
                  _buildPortfolioSummary(),
                  const SizedBox(height: 24),

                  // Insights
                  _buildInsights(),
                  const SizedBox(height: 24),

                  // Rewards
                  _buildRewardsCard(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: _getPerformanceGradient(),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadow3DLarge,
        ),
        child: Column(
          children: [
            Text(
              _getPerformanceEmoji(),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            Text(
              widget.result.performanceRating,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: widget.result.performanceRating == 'Average'
                        ? const Color(0xFF393027)
                        : const Color(0xFF022E17),
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPerformanceMessage(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: (widget.result.performanceRating == 'Average'
                            ? const Color(0xFF393027)
                            : const Color(0xFF022E17))
                        .withAlpha((0.9 * 255).round()),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: (widget.result.performanceRating == 'Average'
                        ? const Color(0xFF393027)
                        : const Color(0xFF022E17))
                    .withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Score: ${widget.result.score}/100',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: widget.result.performanceRating == 'Average'
                          ? const Color(0xFF393027)
                          : const Color(0xFF022E17),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final portfolio = widget.result.portfolio;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Breakdown',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF393027),
                ),
          ),
          const SizedBox(height: 20),
          _buildScoreRow(
            'Return',
            portfolio.returnPercentage,
            const Color(0xFF9BAD50),
            suffix: '%',
          ),
          _buildScoreRow(
            'Diversification',
            portfolio.diversificationScore,
            const Color(0xFFB6CFE4),
            suffix: '/100',
          ),
          _buildScoreRow(
            'Risk Management',
            100 - portfolio.riskScore,
            const Color(0xFFFFC3CC),
            suffix: '/100',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double value, Color color,
      {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF393027)),
              ),
              Text(
                '${value.toStringAsFixed(1)}$suffix',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withAlpha((0.2 * 255).round()),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    final portfolio = widget.result.portfolio;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Summary',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF393027),
                ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Initial Capital',
              '₹${portfolio.totalCapital.toStringAsFixed(0)}'),
          _buildSummaryRow(
              'Final Value', '₹${portfolio.totalValue.toStringAsFixed(0)}'),
          _buildSummaryRow(
            'Total Return',
            '₹${portfolio.totalReturn.toStringAsFixed(0)}',
            valueColor: portfolio.totalReturn >= 0
                ? const Color(0xFF9BAD50)
                : const Color(0xFFFFC3CC),
          ),
          _buildSummaryRow('Return %',
              '${portfolio.returnPercentage.toStringAsFixed(1)}%',
              valueColor: portfolio.returnPercentage >= 0
                  ? const Color(0xFF9BAD50)
                  : const Color(0xFFFFC3CC)),
          _buildSummaryRow('Market Events', '${portfolio.eventsOccurred.length}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF393027)),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: valueColor ?? const Color(0xFF393027),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF393027),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.result.insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9BAD50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF393027)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    // Use server-returned values if available, otherwise use calculated fallback
    final coinsToShow = _coinsEarned > 0 ? _coinsEarned : widget.result.coinsEarned;
    final xpToShow = _xpEarned > 0 ? _xpEarned : widget.result.xpEarned;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF393027), Color(0xFF022E17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DMedium,
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Rewards Earned!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFF6EDA3),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRewardItem(
                Icons.monetization_on,
                '+$coinsToShow',
                'Coins',
              ),
              Container(
                width: 2,
                height: 50,
                color: const Color(0xFFF6EDA3).withAlpha((0.3 * 255).round()),
              ),
              _buildRewardItem(
                Icons.stars,
                '+$xpToShow',
                'XP',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF6EDA3), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFFF6EDA3),
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFF6EDA3).withAlpha((0.9 * 255).round()),
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9BAD50),
              foregroundColor: const Color(0xFF022E17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/game/market-explorer');
            },
            icon: const Icon(Icons.replay),
            label: const Text('Play Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB6CFE4),
              side: const BorderSide(color: Color(0xFFB6CFE4), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _getPerformanceGradient() {
    switch (widget.result.performanceRating) {
      case 'Excellent':
        return const LinearGradient(
          colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Good':
        return const LinearGradient(
          colors: [Color(0xFFB6CFE4), Color(0xFF9BAD50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Average':
        return const LinearGradient(
          colors: [Color(0xFFF6EDA3), Color(0xFFF6EDA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFFC3CC), Color(0xFFFFC3CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getPerformanceEmoji() {
    switch (widget.result.performanceRating) {
      case 'Excellent':
        return '🏆';
      case 'Good':
        return '👍';
      case 'Average':
        return '😐';
      default:
        return '😔';
    }
  }

  String _getPerformanceMessage() {
    switch (widget.result.performanceRating) {
      case 'Excellent':
        return 'Outstanding! You\'re a market expert!';
      case 'Good':
        return 'Well done! You made smart investments.';
      case 'Average':
        return 'Not bad, but there\'s room for improvement.';
      default:
        return 'Keep learning and try different strategies!';
    }
  }
}
