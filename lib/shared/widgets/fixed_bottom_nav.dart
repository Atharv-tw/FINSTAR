import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFFFFF).withValues(alpha: 0.15),
                  const Color(0xFFE8E8FF).withValues(alpha: 0.20),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF4A9FE5).withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated background
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF4A9FE5), Color(0xFF2F7FD1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isSelected
                      ? null
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4A9FE5).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  size: 26,
                  color: widget.isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 3),
              // Label with smooth color transition
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? const Color(0xFF4A9FE5)
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
