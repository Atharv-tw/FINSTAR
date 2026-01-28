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
  late AnimationController _sparkleController;

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

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _controlsController.dispose();
    _sparkleController.dispose();
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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/gemini_Generated_Image_jyboudjyboudjybo-2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withAlpha(153),
          ),
          // Islands and UI
          _buildFloatingIsland(AssetType.fixedDeposit, -0.6, -0.8, 0),
          _buildFloatingIsland(AssetType.sip, 0.6, -0.3, 1),
          _buildFloatingIsland(AssetType.stocks, -0.6, 0.2, 2),
          _buildFloatingIsland(AssetType.crypto, 0.6, 0.7, 3),
          _buildCapitalDisplay(),
          _buildInstructionText(),
          if (_selectedAsset != null) _buildContextualControls(),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _hasInteracted ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Align(
          alignment: Alignment(0, 0.95),
          child: Text(
            'Tap an island to invest!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black.withAlpha(138), blurRadius: 10)]
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFloatingIsland(AssetType type, double alignX, double alignY, int index) {
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
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.yellow.withAlpha(150) : Colors.black.withAlpha(100),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ]
                ),
                child: ClipOval(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/gemini_Generated_Image_jyboudjyboudjybo-2.png'),
                        fit: BoxFit.cover,
                        opacity: 0.9,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 35,
                child: Icon(_getAssetIcon(type), color: Colors.white, size: 40, shadows: [Shadow(color: Colors.black87, blurRadius: 15, offset: Offset(0,2))]),
              ),
              Positioned(
                bottom: 45,
                child: Text(
                  type.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(color: Colors.black87, blurRadius: 15)]),
                ),
              ),
              if (isSelected)
                IgnorePointer(
                  child: CustomPaint(
                    size: const Size(180, 180),
                    painter: SparklePainter(animation: _sparkleController),
                  ),
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
                color: Colors.blue.withAlpha(100),
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

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.fixedDeposit: return Icons.account_balance_wallet;
      case AssetType.sip: return Icons.spa;
      case AssetType.stocks: return Icons.show_chart;
      case AssetType.crypto: return Icons.currency_bitcoin;
    }
  }
}

class SparklePainter extends CustomPainter {
  final Animation<double> animation;
  SparklePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()..color = Colors.white.withAlpha((150 * (1.0 - (animation.value * 2.0 - 1.0).abs())).toInt());
    
    final int sparkleCount = 7;
    for (int i = 0; i < sparkleCount; i++) {
      final double progress = (animation.value + (i / sparkleCount) + random.nextDouble() * 0.1) % 1.0;
      final double angle = 2 * pi * progress;
      final double distance = (size.width / 2.5) * (0.8 + progress * 0.4) * (random.nextDouble() * 0.4 + 0.8);
      final double x = size.width / 2 + cos(angle) * distance;
      final double y = size.height / 2 + sin(angle) * distance;
      final double radius = (1.0 - (progress * 2.0 - 1.0).abs()) * (random.nextDouble() * 2.0 + 2.0);
      if (radius > 0) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) => false;
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