import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

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
    with TickerProviderStateMixin {
  late final DifficultyLevel _selectedDifficulty;
  late final int _totalCapital;
  final Map<AssetType, double> _allocations = {
    AssetType.fixedDeposit: 0,
    AssetType.sip: 0,
    AssetType.stocks: 0,
    AssetType.crypto: 0,
  };
  
  AssetType? _selectedAsset;
  bool _hasInteracted = false;
  
  late AnimationController _floatController;
  late AnimationController _controlsController;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = DifficultyLevelExtension.fromString(widget.difficulty);
    _totalCapital = widget.initialInvestment;
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _controlsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _controlsController.dispose();
    super.dispose();
  }

  double get _allocatedAmount => _allocations.values.fold(0.0, (sum, amount) => sum + amount);
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

  void _selectAsset(AssetType? assetType) {
    setState(() {
      _hasInteracted = true;
      if (_selectedAsset == assetType) {
        _selectedAsset = null;
        _controlsController.reverse();
      } else {
        _selectedAsset = assetType;
        _controlsController.forward(from: 0.0);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Explore the Market', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black38, blurRadius: 10)])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8DB5D6), Color(0xFF7CAFD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingIsland(AssetType.fixedDeposit, -0.6, -0.8, 0),
            _buildFloatingIsland(AssetType.sip, 0.6, -0.3, 1),
            _buildFloatingIsland(AssetType.stocks, -0.6, 0.2, 2),
            _buildFloatingIsland(AssetType.crypto, 0.6, 0.7, 3),
            _buildCapitalDisplay(),
            _buildInstructionText(),
            if (_selectedAsset != null) _buildContextualControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _hasInteracted ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: const Align(
          alignment: Alignment(0, 0.95),
          child: Text(
            'Tap an island to invest!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black54, blurRadius: 10)]
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFloatingIsland(AssetType type, double alignX, double alignY, int index) {
    final allocation = _allocations[type]!;
    final fillPercent = _totalCapital > 0 ? (allocation / _totalCapital).clamp(0.0, 1.0) : 0.0;
    final isSelected = _selectedAsset == type;
    final floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        final offset = index.isEven ? floatAnimation.value : -floatAnimation.value;
        return Align(
          alignment: Alignment(alignX, alignY),
          child: Transform.translate(
            offset: Offset(0, offset),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _selectAsset(type),
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.yellow.withAlpha(150) : Colors.black.withAlpha(50),
                      blurRadius: 25,
                      spreadRadius: 5,
                    )
                  ]
                ),
              ),
              // Main circle with fill effect
              ClipOval(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Empty state background
                    Container(
                      color: Colors.black.withAlpha(30),
                    ),
                    // Filled portion
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      height: 160 * fillPercent,
                      decoration: BoxDecoration(
                        color: _getAssetColor(type),
                      ),
                    ),
                  ],
                ),
              ),
              // Border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(150), width: 2),
                ),
              ),
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getAssetIcon(type), color: Colors.white, size: 40, shadows: const [Shadow(color: Colors.black87, blurRadius: 15, offset: Offset(0,2))]),
                  const SizedBox(height: 8),
                  Text(
                    type.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(color: Colors.black87, blurRadius: 15)]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContextualControls() {
    final assetType = _selectedAsset!;
    final allocation = _allocations[assetType]!;
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controlsController, curve: Curves.easeOutCubic)
        ),
        child: ClipPath(
          clipper: WaveClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(_getAssetIcon(assetType), color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(assetType.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => _selectAsset(null),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Slider(
                    value: allocation,
                    min: 0,
                    max: _totalCapital.toDouble(),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withAlpha(80),
                    onChanged: (value) => _updateAllocation(assetType, value),
                  ),
                  const SizedBox(height: 15),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapitalDisplay() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Remaining', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text(
              '₹${_remainingAmount.toStringAsFixed(0)}',
              style: TextStyle(
                  color: _remainingAmount < 0 ? Colors.red.shade200 : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 10)]),
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
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withAlpha(100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          _canStart ? 'Start 5-Year Simulation' : 'Allocate Money to Start',
          style: TextStyle(
            color: _canStart ? const Color(0xFF0052D4) : Colors.black.withAlpha(100),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _getAssetColor(AssetType type) {
    switch (type) {
      case AssetType.fixedDeposit: return const Color(0xFF6FB1FC);
      case AssetType.sip: return const Color(0xFF9BAD50);
      case AssetType.stocks: return const Color(0xFFFFC3CC);
      case AssetType.crypto: return const Color(0xFFF4A261);
    }
  }

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.fixedDeposit: return Icons.account_balance_wallet;
      case AssetType.sip: return Icons.spa;
      case AssetType.stocks: return Icons.show_chart;
      case AssetType.crypto: return Icons.currency_bitcoin;
    }
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 20); // Start 20px down
    
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2.25, 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), 65);
    var secondEndPoint = Offset(size.width, 10.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
