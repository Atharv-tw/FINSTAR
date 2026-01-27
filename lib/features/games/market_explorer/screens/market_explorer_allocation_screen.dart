import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

import '../models/market_explorer_models.dart';
import 'market_explorer_simulation_screen.dart';

class MarketExplorerAllocationScreen extends StatefulWidget {
  final String difficulty;
  final int initialInvestment;

  const MarketExplorerAllocationScreen({
    super.key,
    required this.difficulty,
    required this.initialInvestment,
  });

  @override
  State<MarketExplorerAllocationScreen> createState() =>
      _MarketExplorerAllocationScreenState();
}

class _MarketExplorerAllocationScreenState
    extends State<MarketExplorerAllocationScreen>
    with SingleTickerProviderStateMixin {
  late final DifficultyLevel _selectedDifficulty;
  late final int _totalCapital;

  final Map<AssetType, double> _allocations = {
    AssetType.fixedDeposit: 0,
    AssetType.sip: 0,
    AssetType.stocks: 0,
    AssetType.crypto: 0,
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = DifficultyLevelExtension.fromString(widget.difficulty);
    _totalCapital = widget.initialInvestment;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _allocatedAmount =>
      _allocations.values.fold(0.0, (sum, amount) => sum + amount);

  double get _remainingAmount => _totalCapital - _allocatedAmount;

  bool get _canStart => _allocatedAmount > 0 && _remainingAmount >= 0;

  void _updateAllocation(AssetType type, double value) {
    setState(() {
      final newTotal = _allocatedAmount - _allocations[type]! + value;
      if (newTotal <= _totalCapital) {
        _allocations[type] = value;
      }
    });
  }

  void _startSimulation() {
    if (!_canStart) return;

    // Create portfolio with allocations
    final portfolio = Portfolio(
      totalCapital: _totalCapital,
      simulationYears: 5,
      difficulty: _selectedDifficulty,
      initialAllocations: _allocations,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketExplorerSimulationScreen(
          portfolio: portfolio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Explorer', style: TextStyle(color: Color(0xFF393027))),
        backgroundColor: const Color(0xFFF6EDA3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF393027)),
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
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Capital Display
                  _buildCapitalDisplay(),
                  const SizedBox(height: 32),

                  // Asset Allocation Cards
                  Text(
                    'Choose Your Islands',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF393027),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Allocate your capital across different investment islands',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF393027).withAlpha((0.7 * 255).round()),
                        ),
                  ),
                  const SizedBox(height: 20),

                  ...AssetType.values.map((type) => _buildAssetCard(type)),

                  const SizedBox(height: 32),

                  // Start Button
                  _buildStartButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9BAD50), Color(0xFFB6CFE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadow3DMedium,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF022E17).withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🏝️', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Markets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF022E17),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invest wisely and watch your portfolio grow over 5 years',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF022E17).withAlpha((0.9 * 255).round()),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapitalDisplay() {
    final progress = _totalCapital > 0 ? _allocatedAmount / _totalCapital : 0.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Capital',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF6EDA3).withAlpha((0.9 * 255).round()),
                        ),
                  ),
                  Text(
                    '₹${_totalCapital.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xFFF6EDA3),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF6EDA3).withAlpha((0.9 * 255).round()),
                        ),
                  ),
                  Text(
                    '₹${_remainingAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _remainingAmount < 0
                              ? const Color(0xFFFFC3CC)
                              : const Color(0xFFF6EDA3),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: const Color(0xFFF6EDA3).withAlpha((0.3 * 255).round()),
              valueColor: AlwaysStoppedAnimation<Color>(
                _remainingAmount < 0 ? const Color(0xFFFFC3CC) : const Color(0xFFB6CFE4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% Allocated',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFF6EDA3).withAlpha((0.9 * 255).round()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(AssetType type) {
    final allocation = _allocations[type]!;
    final maxAllocation = _totalCapital - (_allocatedAmount - allocation);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDA3).withAlpha((0.7 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getAssetColor(type).withAlpha((0.3 * 255).round()),
          width: 2,
        ),
        boxShadow: AppTheme.shadow3DSmall,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getAssetColor(type).withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          title: Text(
            type.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF393027),
                ),
          ),
          subtitle: allocation > 0
              ? Text(
                  '₹${allocation.toStringAsFixed(0)} allocated',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getAssetColor(type),
                        fontWeight: FontWeight.w600,
                      ),
                )
              : null,
          children: [
            Text(
              type.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF393027).withAlpha((0.7 * 255).round()),
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected Return',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF393027)),
                      ),
                      Text(
                        '${(type.baseReturnRate * 100).toStringAsFixed(1)}% /year',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF9BAD50),
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF393027)),
                      ),
                      Text(
                        '${(type.volatility * 100).toStringAsFixed(0)}%',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _getRiskColor(type.volatility),
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: allocation,
                    min: 0,
                    max: maxAllocation,
                    divisions: maxAllocation > 0 ? (maxAllocation / 100).ceil() : 1,
                    activeColor: _getAssetColor(type),
                    onChanged: (value) {
                      _updateAllocation(type, value.roundToDouble());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: Text(
                    '₹${allocation.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getAssetColor(type),
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canStart ? _startSimulation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9BAD50),
          disabledBackgroundColor: const Color(0xFFB6CFE4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _canStart ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              _canStart
                  ? 'Start 5-Year Simulation'
                  : 'Allocate Money to Start',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _canStart ? const Color(0xFF022E17) : const Color(0xFF393027).withAlpha((0.7 * 255).round()),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAssetColor(AssetType type) {
    switch (type) {
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

  Color _getRiskColor(double volatility) {
    if (volatility < 0.1) return const Color(0xFF9BAD50);
    if (volatility < 0.3) return const Color(0xFFF6EDA3);
    return const Color(0xFFFFC3CC);
  }
}
