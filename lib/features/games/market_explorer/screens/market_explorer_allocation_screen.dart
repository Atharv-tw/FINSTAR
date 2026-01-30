import 'package:flutter/material.dart';

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
    extends State<MarketExplorerAllocationScreen> {
  late final DifficultyLevel _selectedDifficulty;
  late final int _totalCapital;
  final Map<AssetType, double> _allocations = {
    AssetType.fixedDeposit: 0,
    AssetType.sip: 0,
    AssetType.stocks: 0,
    AssetType.crypto: 0,
  };

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = DifficultyLevelExtension.fromString(widget.difficulty);
    _totalCapital = widget.initialInvestment;
  }

  double get _allocatedAmount =>
      _allocations.values.fold(0.0, (sum, amount) => sum + amount);
  double get _remainingAmount => _totalCapital - _allocatedAmount;
  bool get _canStart => _allocatedAmount > 0 && _remainingAmount >= 0;

  void _updateAllocation(AssetType type, double value) {
    setState(() {
      final currentAllocation = _allocations[type]!;
      final otherAllocations = _allocatedAmount - currentAllocation;
      final newValue = value.roundToDouble();

      if (otherAllocations + newValue <= _totalCapital) {
        _allocations[type] = newValue;
      } else {
        _allocations[type] = _totalCapital - otherAllocations;
      }
    });
  }

  void _resetAllocations() {
    setState(() {
      for (final type in _allocations.keys) {
        _allocations[type] = 0;
      }
    });
  }

  void _splitEqually() {
    setState(() {
      final per = (_totalCapital / _allocations.length).floorToDouble();
      double total = 0;
      for (final type in _allocations.keys) {
        _allocations[type] = per;
        total += per;
      }
      final remainder = _totalCapital - total;
      if (remainder > 0) {
        _allocations[AssetType.fixedDeposit] = per + remainder;
      }
    });
  }

  void _startSimulation() {
    if (!_canStart) return;
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
      backgroundColor: const Color(0xFFFFFAE3),
      appBar: AppBar(
        title: const Text(
          'Market Explorer',
          style: TextStyle(
            color: Color(0xFF393027),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFFAE3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF393027)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 16),
              _buildSummaryRow(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildAllocationCard(AssetType.fixedDeposit),
              const SizedBox(height: 12),
              _buildAllocationCard(AssetType.sip),
              const SizedBox(height: 12),
              _buildAllocationCard(AssetType.stocks),
              const SizedBox(height: 12),
              _buildAllocationCard(AssetType.crypto),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9BAD50), Color(0xFF7E9346)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9BAD50).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Difficulty: \${_selectedDifficulty.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_graph_rounded, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${_totalCapital.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Allocate your capital across assets',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final remainingColor = _remainingAmount < 0
        ? Colors.red.shade300
        : const Color(0xFF28301C);

    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            label: 'Allocated',
            value: '\$${_allocatedAmount.toStringAsFixed(0)}',
            color: const Color(0xFF393027),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            label: 'Remaining',
            value: '\$${_remainingAmount.toStringAsFixed(0)}',
            color: remainingColor,
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF694A47).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF694A47),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _splitEqually,
            icon: const Icon(Icons.balance),
            label: const Text('Split 4x'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF393027),
              side: BorderSide(color: const Color(0xFF393027).withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetAllocations,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF393027),
              side: BorderSide(color: const Color(0xFF393027).withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationCard(AssetType type) {
    final allocation = _allocations[type]!;
    final color = _getAssetColor(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getAssetIcon(type), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAssetTitle(type),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28301C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getAssetSubtitle(type),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${allocation.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: allocation,
              min: 0,
              max: _totalCapital.toDouble(),
              onChanged: (value) => _updateAllocation(type, value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAE3),
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _canStart ? _startSimulation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF93A840),
              disabledBackgroundColor: const Color(0xFF93A840).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _canStart ? 'Start 5-Year Simulation' : 'Allocate Money to Start',
              style: TextStyle(
                color: _canStart ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAssetTitle(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return 'Cash';
      case AssetType.fixedDeposit:
        return 'Fixed Deposit';
      case AssetType.sip:
        return 'Mutual Fund SIP';
      case AssetType.stocks:
        return 'Stocks';
      case AssetType.crypto:
        return 'Crypto';
    }
  }

  String _getAssetSubtitle(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return 'Instant access, low growth';
      case AssetType.fixedDeposit:
        return 'Stable returns, low risk';
      case AssetType.sip:
        return 'Balanced growth, medium risk';
      case AssetType.stocks:
        return 'High growth, higher swings';
      case AssetType.crypto:
        return 'Very volatile, high risk';
    }
  }

  Color _getAssetColor(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return const Color(0xFFB6CFE4);
      case AssetType.fixedDeposit:
        return const Color(0xFF6FB1FC);
      case AssetType.sip:
        return const Color(0xFF9BAD50);
      case AssetType.stocks:
        return const Color(0xFFFFC3CC);
      case AssetType.crypto:
        return const Color(0xFFF4A261);
    }
  }

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Icons.account_balance_wallet;
      case AssetType.fixedDeposit:
        return Icons.account_balance_wallet;
      case AssetType.sip:
        return Icons.spa;
      case AssetType.stocks:
        return Icons.show_chart;
      case AssetType.crypto:
        return Icons.currency_bitcoin;
    }
  }
}

