import 'package:finstar_app/core/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LifeSwipeTutorialScreen extends StatefulWidget {
  const LifeSwipeTutorialScreen({super.key});

  @override
  State<LifeSwipeTutorialScreen> createState() =>
      _LifeSwipeTutorialScreenState();
}

class _LifeSwipeTutorialScreenState extends State<LifeSwipeTutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _stepController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 2 seconds per step
    );

    _stepController.addListener(() {
      if (_stepController.value >= 0.5 && _currentStep == 0) {
        setState(() {
          _currentStep = 1;
        });
      }
    });

    _stepController.forward();

    _stepController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToGame();
      }
    });
  }

  @override
  void dispose() {
    _stepController.dispose();
    super.dispose();
  }

  void _navigateToGame() {
    // Use pushReplacement to avoid coming back to the tutorial
    GoRouter.of(context).pushReplacement('/game/life-swipe');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E4D2B).withOpacity(0.6), // Dark Green
              DesignTokens.primaryStart.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Skip Button
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: _navigateToGame,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Text(
                        'How it works',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _currentStep == 0
                          ? _buildSwipeStep(
                              key: const ValueKey('step1'),
                              isSwipeRight: true,
                              title: "SWIPE RIGHT = SPEND",
                              subtitle:
                                  "accept the expense. enjoy now, pay later",
                              icon: Icons.swipe_right_alt,
                            )
                          : _buildSwipeStep(
                              key: const ValueKey('step2'),
                              isSwipeRight: false,
                              title: "SWIPE LEFT = SAVE",
                              subtitle:
                                  "skip the expense. be disciplined, build wealth.",
                              icon: Icons.swipe_left_alt,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeStep({
    required Key key,
    required bool isSwipeRight,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      key: key,
      children: [
        SwipingIcon(
          icon: icon,
          swipeRight: isSwipeRight,
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SwipingIcon extends StatefulWidget {
  final IconData icon;
  final bool swipeRight;

  const SwipingIcon({super.key, required this.icon, required this.swipeRight});

  @override
  State<SwipingIcon> createState() => _SwipingIconState();
}

class _SwipingIconState extends State<SwipingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500), // Increased duration
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swipeController,
      builder: (context, child) {
        final curve = CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut);
        final verticalOffset = const Offset(0, -14); // Move up by 14 pixels (additional 4)
        final offset = widget.swipeRight
            ? Tween<Offset>(begin: const Offset(-30, 0), end: const Offset(30, 0))
                .animate(curve)
                .value + verticalOffset
            : Tween<Offset>(begin: const Offset(30, 0), end: const Offset(-30, 0))
                .animate(curve)
                .value + verticalOffset;

        return Transform.translate(
          offset: offset,
          child: Icon(
            widget.icon,
            size: 100,
            color: widget.swipeRight ? Colors.amber : Colors.red.shade400, // Changed color
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
        );
      },
    );
  }
}