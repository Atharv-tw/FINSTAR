import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';

/// Navigation item data model
class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

/// Glassmorphic bottom navigation dock with central FAB
class BlurDock extends StatefulWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final VoidCallback? onFabTap;
  final Function(int)? onItemTap;
  final bool showFab;

  const BlurDock({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onFabTap,
    this.onItemTap,
    this.showFab = true,
  }) : assert(items.length <= 5, 'Maximum 5 navigation items allowed');

  @override
  State<BlurDock> createState() => _BlurDockState();
}

class _BlurDockState extends State<BlurDock>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _rotationAnimation;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 45° in turns (45/360)
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: MotionTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
      if (_menuOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dockWidth = screenWidth * 0.8;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
        // Backdrop if menu open
        if (_menuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: DesignTokens.surfaceOverlay,
              ),
            ),
          ),

        // Radial menu items
        if (_menuOpen) _buildRadialMenu(),

        // Main dock
        Positioned(
          bottom: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: DesignTokens.blurGlassmorphic,
                sigmaY: DesignTokens.blurGlassmorphic,
              ),
              child: Container(
                width: dockWidth.clamp(280.0, 360.0),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: DesignTokens.elevation5(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildNavItems(),
                ),
              ),
            ),
          ),
        ),

        // Central FAB
        if (widget.showFab)
          Positioned(
            bottom: 44, // 20 + (56/2) - (56/2) + 8 elevation
            child: RotationTransition(
              turns: _rotationAnimation,
              child: GestureDetector(
                onTap: widget.onFabTap ?? _toggleMenu,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: DesignTokens.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      ...DesignTokens.elevation4(),
                      ...DesignTokens.primaryGlow(0.4),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: DesignTokens.textPrimary,
                    size: DesignTokens.iconMD,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
    );
  }

  List<Widget> _buildNavItems() {
    return List.generate(widget.items.length, (index) {
      final item = widget.items[index];
      final isSelected = index == widget.selectedIndex;

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onItemTap?.call(index);
        },
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: MotionTokens.fast,
          curve: MotionTokens.easeOut,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? DesignTokens.primarySolid.withValues(alpha: 0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: DesignTokens.iconSM,
              color: isSelected
                  ? DesignTokens.primarySolid
                  : DesignTokens.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRadialMenu() {
    // Radial menu with 3 sub-FABs for games
    const radius = 80.0;
    final games = [
      {'icon': Icons.swipe, 'label': 'Life Swipe', 'angle': -120.0},
      {'icon': Icons.quiz, 'label': 'Quiz Battle', 'angle': 0.0},
      {'icon': Icons.show_chart, 'label': 'Market Explorer', 'angle': 120.0},
    ];

    return Stack(
      children: games.asMap().entries.map((entry) {
        final index = entry.key;
        final game = entry.value;
        final angle = (game['angle'] as double) * (3.14159 / 180);

        final x = radius * (angle == 0 ? 1 : (angle < 0 ? -0.5 : 0.5));
        final y = radius * (angle == 0 ? 0 : -0.866); // cos/sin for 120°

        return Positioned(
          bottom: 44,
          left: MediaQuery.of(context).size.width / 2 - 24,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: _menuOpen ? 1.0 : 0.0),
            duration: MotionTokens.medium +
                Duration(milliseconds: 60 * index), // Stagger
            curve: MotionTokens.bounceOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(x * value, y * value),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _toggleMenu();
                // TODO: Navigate to game screen
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: DesignTokens.secondaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    ...DesignTokens.elevation3(),
                    ...DesignTokens.secondaryGlow(0.4),
                  ],
                ),
                child: Icon(
                  game['icon'] as IconData,
                  color: DesignTokens.textPrimary,
                  size: DesignTokens.iconSM,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
