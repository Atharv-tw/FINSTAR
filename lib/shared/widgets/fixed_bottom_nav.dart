import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';

/// Premium floating navigation bar with glassmorphic design
class FixedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FixedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 17),
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF393027),
        borderRadius: BorderRadius.circular(31),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF393027).withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap(0);
                },
              ),
              _NavBarItem(
                icon: Icons.videogame_asset_rounded,
                label: 'Play',
                isSelected: currentIndex == 1,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap(1);
                },
              ),
              _NavBarItem(
                icon: Icons.leaderboard_rounded,
                label: 'Leaderboard',
                isSelected: currentIndex == 2,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap(2);
                },
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated background
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? DesignTokens.primaryGradient
                      : null,
                  color: widget.isSelected
                      ? null
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: DesignTokens.primarySolid.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              // Label with smooth color transition
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? DesignTokens.primarySolid
                      : Colors.white.withValues(alpha: 0.6),
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
