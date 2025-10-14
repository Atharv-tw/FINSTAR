import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';
import '../../shared/widgets/xp_ring.dart';
import '../../shared/widgets/coin_pill.dart';
import '../../shared/widgets/finance_tiles_section.dart';
import '../../shared/widgets/dual_progress_dial.dart';
import '../../shared/widgets/daily_streak_card.dart';
import '../../shared/widgets/featured_hero_card.dart';
import '../../shared/widgets/streak_title_bar.dart';

/// FINSTAR Home Screen - Redesigned for maximum impact
class BasicHomeScreen extends StatefulWidget {
  const BasicHomeScreen({super.key});

  @override
  State<BasicHomeScreen> createState() => _BasicHomeScreenState();
}

class _BasicHomeScreenState extends State<BasicHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _progressController;
  late AnimationController _pandaController;
  late AnimationController _breathingController;

  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _progressScaleAnimation;
  late Animation<double> _pandaSlideAnimation;

  // User data
  final String _userName = "Star";
  final int _userLevel = 5;
  final int _currentXp = 750;
  final int _xpForNextLevel = 1000;
  final int _coins = 340;
  final double _studyProgress = 0.65; // 65% study progress
  final int _streakDays = 7;

  @override
  void initState() {
    super.initState();

    // Greeting animation
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeOut),
    );
    _greetingSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeOutQuart),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.elasticOut),
    );

    // Panda animation
    _pandaController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pandaSlideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _pandaController, curve: Curves.easeOutQuart),
    );

    // Breathing animation for panda
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Trigger animations sequentially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _greetingController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _progressController.forward();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _pandaController.forward();
      });
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _progressController.dispose();
    _pandaController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Vibrant animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: DesignTokens.vibrantBackgroundGradient,
            ),
          ),

          // Main scrollable content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak Title Bar at top
                StreakTitleBar(streakDays: _streakDays),

                const SizedBox(height: 8),

                // Content with padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 110),

                      // Progress Section with Panda
                      _buildProgressWithPandaSection(screenWidth),

                    const SizedBox(height: 12),

                    // Featured Hero Card
                    FeaturedHeroCard(
                      onTap: () => context.go('/game'),
                    ),

                      // Learning Categories
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: const FinanceTilesSection(),
                      ),

                      const SizedBox(height: 24), // Bottom spacing
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return AnimatedBuilder(
      animation: _greetingController,
      builder: (context, child) {
        return SlideTransition(
          position: _greetingSlideAnimation,
          child: FadeTransition(
            opacity: _greetingFadeAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level counter dial (tap to open profile)
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: XpRing(
                    currentXp: _currentXp,
                    xpForNextLevel: _xpForNextLevel,
                    level: _userLevel,
                    size: 56,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressWithPandaSection(double screenWidth) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _pandaController, _breathingController]),
      builder: (context, child) {
        final breathingScale = 1.0 + (_breathingController.value * 0.045);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Progress card
            Transform.scale(
              scale: _progressScaleAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 26, 73, 128).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withValues(alpha: 0.15),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // XP Ring
                        XpRing(
                          currentXp: _currentXp,
                          xpForNextLevel: _xpForNextLevel,
                          level: _userLevel,
                          size: 60,
                        ),

                        const SizedBox(width: 16),

                        // Progress bars
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Level progress
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Level Progress',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '$_currentXp / $_xpForNextLevel XP',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildProgressBar(_currentXp / _xpForNextLevel, DesignTokens.primaryGradient),

                              const SizedBox(height: 16),

                              // Study progress
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Study Progress',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${(_studyProgress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildProgressBar(_studyProgress, DesignTokens.secondaryGradient),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Panda sitting on right top corner
            Positioned(
              right: -70,
              top: -169,
              child: Transform.translate(
                offset: Offset(0, _pandaSlideAnimation.value),
                child: FadeTransition(
                  opacity: _pandaController,
                  child: Transform.scale(
                    scale: breathingScale,
                    child: Image.asset(
                      'assets/images/pandahome.png',
                      width: screenWidth * 0.7,
                      height: screenWidth * 0.7,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // "Hello" text
            Positioned(
              left: 1,
              top: -117,
              child: FadeTransition(
                opacity: _pandaController,
                child: Text(
                  'Hello',
                  style: GoogleFonts.silkscreen(
                    fontSize: 43,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // "STAR!" text
            Positioned(
              left: 1,
              top: -73,
              child: FadeTransition(
                opacity: _pandaController,
                child: Text(
                  'STAR!',
                  style: GoogleFonts.silkscreen(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _buildProgressBar(double progress, LinearGradient gradient) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Stack(
          children: [
            // Background bar
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Progress bar with glow
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors[0].withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
