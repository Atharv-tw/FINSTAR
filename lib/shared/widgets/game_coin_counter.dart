import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium gaming-style coin counter widget with shine effects and animations.
/// Inspired by mobile gaming apps like Clash of Clans, Candy Crush, etc.
class GameCoinCounter extends StatefulWidget {
  final int coins;
  final VoidCallback? onTap;
  final bool showPlusButton;
  final bool animate;

  const GameCoinCounter({
    super.key,
    required this.coins,
    this.onTap,
    this.showPlusButton = true,
    this.animate = true,
  });

  @override
  State<GameCoinCounter> createState() => _GameCoinCounterState();
}

class _GameCoinCounterState extends State<GameCoinCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  int _displayedCoins = 0;

  @override
  void initState() {
    super.initState();
    _displayedCoins = widget.coins;
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void didUpdateWidget(GameCoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins && widget.animate) {
      _animateCoinChange(oldWidget.coins, widget.coins);
    } else {
      _displayedCoins = widget.coins;
    }
  }

  void _animateCoinChange(int from, int to) {
    final diff = to - from;
    final steps = diff.abs().clamp(1, 20);
    final stepValue = diff / steps;
    int currentStep = 0;

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return false;
      currentStep++;
      setState(() {
        _displayedCoins = (from + (stepValue * currentStep)).round();
      });
      return currentStep < steps;
    }).then((_) {
      if (mounted) {
        setState(() => _displayedCoins = to);
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          // Soft olive/sage green to match app's earthy palette
          color: const Color(0xFF5C6B4A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin icon
            _buildCoinIcon(),
            // Coin count
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                _formatCoins(_displayedCoins),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Plus button
            if (widget.showPlusButton) _buildPlusButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/coin.png',
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image fails to load
            return Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFFEB3B), Color(0xFFFFC107)],
                ),
              ),
              child: const Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB8860B),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlusButton() {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4CAF50), // Green
            Color(0xFF388E3C), // Dark green
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: const Color(0xFF81C784),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}
