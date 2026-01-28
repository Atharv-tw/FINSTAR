import 'package:flutter/material.dart';
import 'dart:math';

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
  
  late AnimationController _pulseController;
  late AnimationController _controlsController;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = DifficultyLevelExtension.fromString(widget.difficulty);
    _totalCapital = widget.initialInvestment;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _controlsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      appBar: AppBar(
        title: const Text('Allocate Your Capital', style: TextStyle(color: Color(0xFF393027), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFFAE3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF393027)),
      ),
      body: Container(
        color: const Color(0xFFFFFAE3),
        child: Stack(
          children: [
            _buildIslandWidget(AssetType.fixedDeposit, const Alignment(-0.8, -0.6)),
            _buildIslandWidget(AssetType.sip, const Alignment(0.8, -0.6)),
            _buildIslandWidget(AssetType.stocks, const Alignment(-0.5, 0.15)),
            _buildIslandWidget(AssetType.crypto, const Alignment(0.5, 0.15)),
            
            _buildCapitalDisplay(),
            
            _buildInstructionText(),

            if (_selectedAsset != null) _buildContextualControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return AnimatedOpacity(
      opacity: _hasInteracted ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: const Align(
        alignment: Alignment(0, 0.5),
        child: Text(
          'Tap an island to invest!',
          style: TextStyle(
            color: Color(0xFF393027),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildIslandWidget(AssetType type, Alignment alignment) {
    final allocation = _allocations[type]!;
    final isSelected = _selectedAsset == type;

    Widget island = GestureDetector(
      onTap: () => _selectAsset(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isSelected ? 150 : 130,
        height: isSelected ? 150 : 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shadow
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            ),
            // Island Base (Earth)
            Positioned(
              bottom: 0,
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFa0522d),
                  borderRadius: const BorderRadius.all(Radius.circular(60)),
                ),
              ),
            ),
            // Island Top (Grass)
            Positioned(
              top: 10,
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: _getAssetColor(type).withAlpha(200),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                ),
              ),
            ),
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getAssetIcon(type), color: const Color(0xFF022E17), size: 28),
                const SizedBox(height: 4),
                Text(
                  type.name,
                  style: const TextStyle(
                      color: Color(0xFF393027),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${allocation.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    return Align(
      alignment: alignment,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.02).animate(_pulseController),
        child: island,
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
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          decoration: const BoxDecoration(
            color: Color(0xFF393027),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asset Info and Slider
              Row(
                children: [
                  Icon(_getAssetIcon(assetType), color: _getAssetColor(assetType), size: 24),
                  const SizedBox(width: 12),
                  Text(assetType.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _selectAsset(null),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Slider(
                value: allocation,
                min: 0,
                max: _totalCapital.toDouble(),
                activeColor: _getAssetColor(assetType),
                inactiveColor: _getAssetColor(assetType).withAlpha(50),
                onChanged: (value) {
                  _updateAllocation(assetType, value);
                },
              ),
              const SizedBox(height: 20),
              // Close button or Start Simulation
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapitalDisplay() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF393027).withAlpha(220),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Remaining Capital', style: TextStyle(color: Color(0xFFB6CFE4), fontSize: 14)),
            Text(
              '₹${_remainingAmount.toStringAsFixed(0)}',
              style: TextStyle(
                  color: _remainingAmount < 0 ? const Color(0xFFFFC3CC) : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _canStart ? 4 : 0,
        ),
        child: Text(
          _canStart ? 'Start 5-Year Simulation' : 'Allocate Money to Start',
          style: TextStyle(
            color: _canStart ? const Color(0xFF022E17) : const Color(0xFF393027).withAlpha(180),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _getAssetColor(AssetType type) {
    switch (type) {
      case AssetType.fixedDeposit: return const Color(0xFFB6CFE4);
      case AssetType.sip: return const Color(0xFF9BAD50);
      case AssetType.stocks: return const Color(0xFFFFC3CC);
      case AssetType.crypto: return const Color(0xFFF4A261);
    }
  }

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.fixedDeposit: return Icons.account_balance;
      case AssetType.sip: return Icons.show_chart;
      case AssetType.stocks: return Icons.bar_chart;
      case AssetType.crypto: return Icons.currency_bitcoin;
    }
  }
}

class IslandPainter extends CustomPainter {
  final Color color;
  final double fillPercent;
  final bool isSelected;

  IslandPainter({required this.color, required this.fillPercent, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path path = Path()
      ..moveTo(w * 0.5, h * 0.0)
      ..quadraticBezierTo(w * 0.1, h * 0.2, w * 0.2, h * 0.5)
      ..quadraticBezierTo(w * 0.0, h * 0.8, w * 0.5, h * 0.95)
      ..quadraticBezierTo(w * 1.0, h * 0.8, w * 0.8, h * 0.5)
      ..quadraticBezierTo(w * 0.9, h * 0.2, w * 0.5, h * 0.0)
      ..close();
    
    // Island Fill
    canvas.drawPath(path, Paint()..color = color.withAlpha(100));

    // Water Fill
    final Rect bounds = path.getBounds();
    final double fillHeight = bounds.height * fillPercent.clamp(0.0, 1.0);
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(bounds.left, bounds.bottom - fillHeight, bounds.width, fillHeight),
      Paint()..color = color.withAlpha(200),
    );

    // Island Stroke
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = isSelected ? 5 : 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Glowing effect if selected
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant IslandPainter oldDelegate) {
    return oldDelegate.fillPercent != fillPercent ||
           oldDelegate.color != color ||
           oldDelegate.isSelected != isSelected;
  }
}

