import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme.dart';
import '../models/market_explorer_models.dart';
import '../services/market_simulator.dart';
import 'market_explorer_result_screen.dart';

class MarketExplorerSimulationScreen extends StatefulWidget {
  final Portfolio portfolio;

  const MarketExplorerSimulationScreen({
    super.key,
    required this.portfolio,
  });

  @override
  State<MarketExplorerSimulationScreen> createState() =>
      _MarketExplorerSimulationScreenState();
}

class _MarketExplorerSimulationScreenState
    extends State<MarketExplorerSimulationScreen>
    with TickerProviderStateMixin {
  late MarketSimulator _simulator;
  late AnimationController _yearProgressController;
  late AnimationController _chartAnimationController;

  List<SimulationYearResult> _yearResults = [];
  int _currentYear = 0;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _simulator = MarketSimulator(difficulty: widget.portfolio.difficulty);

    _yearProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start simulation automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSimulation();
    });
  }

  @override
  void dispose() {
    _yearProgressController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startSimulation() async {
    setState(() {
      _isSimulating = true;
      _currentYear = 0;
      _yearResults.clear();
    });

    // Simulate year by year with animation
    for (int year = 1; year <= widget.portfolio.simulationYears; year++) {
      await Future.delayed(const Duration(milliseconds: 500));

      final yearResult = _simulator.simulateYear(widget.portfolio);

      setState(() {
        _yearResults.add(yearResult);
        _currentYear = year;
      });

      // Animate progress
      _yearProgressController.reset();
      await _yearProgressController.forward();

      // Animate chart
      _chartAnimationController.reset();
      await _chartAnimationController.forward();

      // Show event if any
      if (yearResult.hasEvent) {
        await _showEventDialog(yearResult.event!);
      }

      // Allow rebalancing at year 3
      if (year == 3) {
        await _offerRebalancing();
      }
    }

    setState(() {
      _isSimulating = false;
    });

    // Show results after a brief pause
    await Future.delayed(const Duration(milliseconds: 1000));
    _navigateToResults();
  }

  Future<void> _showEventDialog(MarketEvent event) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(event.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Text(event.description),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _offerRebalancing() async {
    final shouldRebalance = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⚖️', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rebalance Portfolio?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Text(
          'You\'ve reached Year 3. Want to adjust your allocations based on market performance?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Continue'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gamesColor,
            ),
            child: const Text('Yes, Rebalance'),
          ),
        ],
      ),
    );

    if (shouldRebalance == true && mounted) {
      await _showRebalancingDialog();
    }
  }

  Future<void> _showRebalancingDialog() async {
    // Show rebalancing UI (simplified version for now)
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rebalancing'),
        content: Text(
          'Rebalancing interface would go here. For now, continuing with current allocation.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToResults() {
    final result = SimulationResult.calculate(widget.portfolio);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MarketExplorerResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Simulation'),
        actions: [
          if (_isSimulating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year Progress
              _buildYearProgress(),
              const SizedBox(height: 24),

              // Portfolio Value Card
              _buildPortfolioValueCard(),
              const SizedBox(height: 24),

              // Chart
              _buildChart(),
              const SizedBox(height: 24),

              // Asset Performance
              if (_currentYear > 0) _buildAssetPerformance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DMedium,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Year $_currentYear / ${widget.portfolio.simulationYears}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_isSimulating)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Simulating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _currentYear / widget.portfolio.simulationYears,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValueCard() {
    final currentValue = widget.portfolio.totalValue;
    final returnAmount = widget.portfolio.totalReturn;
    final returnPct = widget.portfolio.returnPercentage;
    final isPositive = returnAmount >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DMedium,
      ),
      child: Column(
        children: [
          Text(
            'Portfolio Value',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${currentValue.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? '+' : ''}₹${returnAmount.toStringAsFixed(0)} (${returnPct.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (widget.portfolio.totalValueHistory.length < 2) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.shadow3DSmall,
        ),
        child: Center(
          child: Text(
            'Chart will appear as simulation progresses',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < widget.portfolio.totalValueHistory.length; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        widget.portfolio.totalValueHistory[i],
      ));
    }

    final minY = widget.portfolio.totalValueHistory.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = widget.portfolio.totalValueHistory.reduce((a, b) => a > b ? a : b) * 1.1;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Growth',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'Y${value.toInt()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.successColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.successColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Performance',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        ...widget.portfolio.assets.entries.map((entry) {
          final asset = entry.value;
          final returnPct = asset.returnPercentage;
          final isPositive = returnPct >= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getAssetColor(asset.type).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(asset.type.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.type.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '₹${asset.currentValue.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPositive
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${returnPct.toStringAsFixed(1)}%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isPositive
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Text(
                      '${isPositive ? '+' : ''}₹${asset.totalReturn.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getAssetColor(AssetType type) {
    switch (type) {
      case AssetType.fixedDeposit:
        return AppTheme.successColor;
      case AssetType.sip:
        return AppTheme.gamesColor;
      case AssetType.stocks:
        return AppTheme.quizColor;
      case AssetType.crypto:
        return AppTheme.streakColor;
    }
  }
}
