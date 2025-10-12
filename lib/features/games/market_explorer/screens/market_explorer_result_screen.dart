import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../models/market_explorer_models.dart';
import '../../../../models/game_progress_model.dart';
import '../../../../services/local_storage_service.dart';

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
      final storage = LocalStorageService.getInstance();

      // Add coins and XP rewards
      await storage.addReward(
        coins: widget.result.coinsEarned,
        xp: widget.result.xpEarned,
      );

      // Update game progress
      final existingProgress = await storage.getGameProgress('market_explorer') as GameProgressModel?;
      final updatedProgress = existingProgress != null
          ? GameProgressModel(
              gameId: existingProgress.gameId,
              gameName: existingProgress.gameName,
              highScore: widget.result.score > existingProgress.highScore
                  ? widget.result.score
                  : existingProgress.highScore,
              timesPlayed: existingProgress.timesPlayed + 1,
              lastPlayed: DateTime.now(),
              isCompleted: existingProgress.isCompleted,
              gameData: existingProgress.gameData,
            )
          : GameProgressModel(
              gameId: 'market_explorer',
              gameName: 'Market Explorer',
              highScore: widget.result.score,
              timesPlayed: 1,
              lastPlayed: DateTime.now(),
              isCompleted: false,
              gameData: {},
            );

      await storage.updateGameProgress(updatedProgress);
    } catch (e) {
      debugPrint('Error claiming rewards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
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
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPerformanceMessage(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Score: ${widget.result.score}/100',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Breakdown',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          _buildScoreRow(
            'Return',
            portfolio.returnPercentage,
            AppTheme.successColor,
            suffix: '%',
          ),
          _buildScoreRow(
            'Diversification',
            portfolio.diversificationScore,
            AppTheme.gamesColor,
            suffix: '/100',
          ),
          _buildScoreRow(
            'Risk Management',
            100 - portfolio.riskScore,
            AppTheme.warningColor,
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
                style: Theme.of(context).textTheme.titleMedium,
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
              backgroundColor: color.withOpacity(0.2),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Summary',
            style: Theme.of(context).textTheme.headlineMedium,
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
                ? AppTheme.successColor
                : AppTheme.errorColor,
          ),
          _buildSummaryRow('Return %',
              '${portfolio.returnPercentage.toStringAsFixed(1)}%',
              valueColor: portfolio.returnPercentage >= 0
                  ? AppTheme.successColor
                  : AppTheme.errorColor),
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
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: valueColor ?? AppTheme.textPrimary,
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
        color: Theme.of(context).colorScheme.surface,
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
                style: Theme.of(context).textTheme.headlineMedium,
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
                      decoration: BoxDecoration(
                        color: AppTheme.gamesColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyLarge,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientGold,
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRewardItem(
                Icons.monetization_on,
                '+${widget.result.coinsEarned}',
                'Coins',
              ),
              Container(
                width: 2,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildRewardItem(
                Icons.stars,
                '+${widget.result.xpEarned}',
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
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
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
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gamesColor,
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.replay),
            label: const Text('Play Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gamesColor,
              side: const BorderSide(color: AppTheme.gamesColor, width: 2),
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
        return LinearGradient(
          colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Good':
        return LinearGradient(
          colors: [AppTheme.gamesColor, AppTheme.gamesColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Average':
        return LinearGradient(
          colors: [AppTheme.warningColor, AppTheme.warningColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.8)],
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
