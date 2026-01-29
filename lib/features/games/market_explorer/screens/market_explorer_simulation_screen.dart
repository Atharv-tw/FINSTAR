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

enum EventDecision { stayCourse, shiftSafety, leanIn }

enum EventSentiment { positive, negative, mixed }

class _MarketExplorerSimulationScreenState
    extends State<MarketExplorerSimulationScreen>
    with TickerProviderStateMixin {
  late MarketSimulator _simulator;
  late AnimationController _yearProgressController;
  late AnimationController _chartAnimationController;

  final List<SimulationYearResult> _yearResults = [];
  int _currentYear = 0;
  bool _isSimulating = false;
  int _decisionsCount = 0;
  int _correctDecisions = 0;

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
        final decision = await _showEventDialog(yearResult.event!);
        if (decision != null) {
          _applyEventDecision(yearResult.event!, decision);
        }
      }

      // Allow rebalancing based on difficulty
      if (year == widget.portfolio.difficulty.rebalanceYear) {
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

  Future<EventDecision?> _showEventDialog(MarketEvent event) async {
    return showDialog<EventDecision>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6EDA3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(event.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF393027)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: TextStyle(color: const Color(0xFF393027).withAlpha((0.8 * 255).round())),
            ),
            const SizedBox(height: 12),
            Text(
              'How will you react?',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: const Color(0xFF393027)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, EventDecision.stayCourse),
            child: const Text('Stay Course', style: TextStyle(color: Color(0xFF393027))),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, EventDecision.shiftSafety),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF393027),
              side: const BorderSide(color: Color(0xFF393027)),
            ),
            child: const Text('Shift to Safety'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, EventDecision.leanIn),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9BAD50)),
            child: const Text('Lean In', style: TextStyle(color: Color(0xFF022E17))),
          ),
        ],
      ),
    );
  }

  EventSentiment _getEventSentiment(MarketEvent event) {
    double sum = 0;
    int count = 0;
    for (var multiplier in event.impactMultipliers.values) {
      sum += multiplier;
      count += 1;
    }
    final avg = count == 0 ? 1.0 : sum / count;
    if (avg >= 1.1) return EventSentiment.positive;
    if (avg <= 0.9) return EventSentiment.negative;
    return EventSentiment.mixed;
  }

  EventDecision _getRecommendedDecision(EventSentiment sentiment) {
    switch (sentiment) {
      case EventSentiment.positive:
        return EventDecision.leanIn;
      case EventSentiment.negative:
        return EventDecision.shiftSafety;
      case EventSentiment.mixed:
        return EventDecision.stayCourse;
    }
  }

  void _applyEventDecision(MarketEvent event, EventDecision decision) {
    _decisionsCount++;
    final sentiment = _getEventSentiment(event);
    final recommended = _getRecommendedDecision(sentiment);
    if (decision == recommended) {
      _correctDecisions++;
    }

    if (decision == EventDecision.stayCourse) {
      return;
    }

    final totalValue = widget.portfolio.totalValue;
    if (totalValue <= 0) return;

    final currentPercentages = <AssetType, double>{};
    for (var entry in widget.portfolio.assets.entries) {
      currentPercentages[entry.key] =
          (entry.value.currentValue / totalValue) * 100;
    }

    final target = Map<AssetType, double>.from(currentPercentages);
    if (decision == EventDecision.shiftSafety) {
      target[AssetType.fixedDeposit] =
          (target[AssetType.fixedDeposit] ?? 0) + 8;
      target[AssetType.sip] = (target[AssetType.sip] ?? 0) + 4;
      target[AssetType.stocks] = (target[AssetType.stocks] ?? 0) - 6;
      target[AssetType.crypto] = (target[AssetType.crypto] ?? 0) - 6;
    } else if (decision == EventDecision.leanIn) {
      target[AssetType.stocks] = (target[AssetType.stocks] ?? 0) + 6;
      target[AssetType.crypto] = (target[AssetType.crypto] ?? 0) + 6;
      target[AssetType.fixedDeposit] =
          (target[AssetType.fixedDeposit] ?? 0) - 8;
      target[AssetType.cash] = (target[AssetType.cash] ?? 0) - 4;
    }

    _normalizeAllocations(target);
    _simulator.rebalancePortfolio(widget.portfolio, target);
  }

  void _normalizeAllocations(Map<AssetType, double> allocations) {
    double total = 0;
    allocations.forEach((key, value) {
      allocations[key] = value.clamp(0, 100);
      total += allocations[key]!;
    });

    if (total == 0) return;
    allocations.updateAll((key, value) => (value / total) * 100);
  }

  Future<void> _offerRebalancing() async {
    final shouldRebalance = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6EDA3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⚖️', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rebalance Portfolio?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF393027)),
              ),
            ),
          ],
        ),
        content: Text(
          'You\'ve reached Year 3. Want to adjust your allocations based on market performance?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF393027).withAlpha((0.8 * 255).round())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Continue', style: TextStyle(color: Color(0xFF393027))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9BAD50),
            ),
            child: const Text('Yes, Rebalance', style: TextStyle(color: Color(0xFF022E17))),
          ),
        ],
      ),
    );

    if (shouldRebalance == true && mounted) {
      await _showRebalancingDialog();
    }
  }

  Future<void> _showRebalancingDialog() async {
    final totalValue = widget.portfolio.totalValue;
    if (totalValue <= 0) return;

    final assetTypes = [
      AssetType.fixedDeposit,
      AssetType.sip,
      AssetType.stocks,
      AssetType.crypto,
    ];

    final percentages = <AssetType, double>{};
    for (var entry in widget.portfolio.assets.entries) {
      percentages[entry.key] =
          (entry.value.currentValue / totalValue) * 100;
    }
    percentages[AssetType.cash] = percentages[AssetType.cash] ?? 0;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double nonCashTotal = 0;
            for (var type in assetTypes) {
              nonCashTotal += percentages[type] ?? 0;
            }
            final cashValue = (100 - nonCashTotal).clamp(0, 100);
            percentages[AssetType.cash] = cashValue.toDouble();

            return AlertDialog(
              backgroundColor: const Color(0xFFF6EDA3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Rebalance Portfolio', style: TextStyle(color: Color(0xFF393027))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...assetTypes.map((type) {
                      final otherTotal = nonCashTotal - (percentages[type] ?? 0);
                      final maxValue = (100 - otherTotal).clamp(0, 100).toDouble();
                      final currentValue = (percentages[type] ?? 0).clamp(0.0, maxValue);
                      if (currentValue != (percentages[type] ?? 0)) {
                        percentages[type] = currentValue;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${type.name}: ${currentValue.toStringAsFixed(1)}%',
                              style: const TextStyle(color: Color(0xFF393027))),
                          Slider(
                            value: currentValue,
                            min: 0,
                            max: maxValue,
                            activeColor: const Color(0xFF9BAD50),
                            inactiveColor: const Color(0xFF393027).withAlpha((0.2 * 255).round()),
                            onChanged: (value) {
                              setState(() {
                                percentages[type] = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                    const Divider(),
                    Text('Cash: ${percentages[AssetType.cash]!.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Color(0xFF393027))),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF393027))),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newAllocations = <AssetType, double>{};
                    for (var entry in percentages.entries) {
                      newAllocations[entry.key] = entry.value;
                    }

                    widget.portfolio.preRebalanceDiversification =
                        widget.portfolio.diversificationScore;
                    widget.portfolio.preRebalanceRisk =
                        widget.portfolio.riskScore;
                    widget.portfolio.rebalanced = true;
                    _simulator.rebalancePortfolio(widget.portfolio, newAllocations);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9BAD50)),
                  child: const Text('Apply', style: TextStyle(color: Color(0xFF022E17))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToResults() {
    widget.portfolio.decisionsCount = _decisionsCount;
    widget.portfolio.correctDecisions = _correctDecisions;
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
        title: const Text('Market Simulation', style: TextStyle(color: Color(0xFF393027))),
        backgroundColor: const Color(0xFFF6EDA3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF393027)),
        actions: [
          if (_isSimulating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF393027))),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFFAE3),
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildYearProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                      color: const Color(0xFF022E17),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_isSimulating)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF022E17).withAlpha((0.2 * 255).round()),
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
                              AlwaysStoppedAnimation<Color>(Color(0xFF022E17)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Simulating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF022E17),
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
              backgroundColor: const Color(0xFF022E17).withAlpha((0.3 * 255).round()),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF022E17)),
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
          Text(
            'Portfolio Value',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFF6EDA3).withAlpha((0.9 * 255).round()),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${currentValue.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: const Color(0xFFF6EDA3),
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? const Color(0xFF9BAD50) : const Color(0xFFFFC3CC),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? '+' : ''}₹${returnAmount.toStringAsFixed(0)} (${returnPct.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isPositive ? const Color(0xFF9BAD50) : const Color(0xFFFFC3CC),
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
          color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.shadow3DSmall,
        ),
        child: Center(
          child: Text(
            'Chart will appear as simulation progresses',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF393027).withAlpha((0.7 * 255).round()),
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
        color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Growth',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF393027)),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF393027)),
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
                    color: const Color(0xFF9BAD50),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF9BAD50).withAlpha((0.1 * 255).round()),
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF393027),
              ),
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
              color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getAssetColor(asset.type).withAlpha((0.3 * 255).round()),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF393027)),
                      ),
                      Text(
                        '₹${asset.currentValue.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF393027).withAlpha((0.7 * 255).round()),
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
                              ? const Color(0xFF9BAD50)
                              : const Color(0xFFFFC3CC),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${returnPct.toStringAsFixed(1)}%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isPositive
                                        ? const Color(0xFF9BAD50)
                                        : const Color(0xFFFFC3CC),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Text(
                      '${isPositive ? '+' : ''}₹${asset.totalReturn.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF393027).withAlpha((0.7 * 255).round()),
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
      case AssetType.cash:
        return const Color(0xFFB6CFE4);
      case AssetType.fixedDeposit:
        return const Color(0xFFB6CFE4);
      case AssetType.sip:
        return const Color(0xFF9BAD50);
      case AssetType.stocks:
        return const Color(0xFFFFC3CC);
      case AssetType.crypto:
        return const Color(0xFF393027);
    }
  }
}
