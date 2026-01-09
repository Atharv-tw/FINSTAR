import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';
import '../../shared/widgets/xp_ring.dart';
import '../../shared/widgets/finance_tiles_section.dart';
import '../../shared/widgets/featured_hero_card.dart';
import '../../shared/widgets/streak_title_bar.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/nature_background.dart';

/// FINSTAR Home Screen - Redesigned for maximum impact
class BasicHomeScreen extends ConsumerStatefulWidget {
  const BasicHomeScreen({super.key});

  @override
  ConsumerState<BasicHomeScreen> createState() => _BasicHomeScreenState();
}

class _BasicHomeScreenState extends ConsumerState<BasicHomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _greetingController;
  late AnimationController _progressController;
  late AnimationController _pandaController;
  late AnimationController _breathingController;

  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _progressScaleAnimation;
  late Animation<double> _pandaSlideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

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
    _scrollController.dispose();
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

    // Get real user data from Firebase
    final userDataAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Calm Nature Background
          const NatureBackground(),

          // Main scrollable content
          userDataAsync.when(
            data: (userData) {
              if (userData == null) {
                return const Center(child: Text('No user data'));
              }

              return SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Title Bar at top
                    StreakTitleBar(streakDays: userData.streakDays),

                    const SizedBox(height: 118),

                    // Padded Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Section with Panda
                          _buildProgressWithPandaSection(screenWidth, userData),

                          const SizedBox(height: 12),

                          // Featured Hero Card
                          FeaturedHeroCard(
                            onTap: () => context.go('/game'),
                          ),
                        ],
                      ),
                    ),

                    // Learning Categories - Full Width
                    FinanceTilesSection(scrollController: _scrollController),

                    const SizedBox(height: 120), // Bottom spacing for nav bar
                  ],
                ),
              );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildProgressWithPandaSection(double screenWidth, dynamic userData) {
    // Calculate XP for next level
    final xpForNextLevel = (userData.level * 1000);
    final studyProgress = 0.65; // TODO: Calculate from learning progress
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          currentXp: userData.xp,
                          xpForNextLevel: xpForNextLevel,
                          level: userData.level,
                          size: 48,
                        ),

                        const SizedBox(width: 12),

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
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${userData.xp} / $xpForNextLevel XP',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _buildProgressBar(userData.xp / xpForNextLevel, DesignTokens.primaryGradient),

                              const SizedBox(height: 10),

                              // Study progress
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Study Progress',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${(studyProgress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _buildProgressBar(studyProgress, DesignTokens.secondaryGradient),
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

            // Centered "Hello STAR!" - Fitted perfectly in the gap
            Positioned(
              left: 8,
              top: -115, // Lowered to stay within the upper boundary
              width: screenWidth * 0.6,
              height: 115, // Matched to the gap size
              child: FadeTransition(
                opacity: _pandaController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 0.8,
                        color: Colors.white,
                        letterSpacing: 3.5, // Increased horizontally
                        shadows: [
                          Shadow(
                            color: const Color(0xFF2E5BFF).withValues(alpha: 0.8),
                            offset: const Offset(1.5, 1.5),
                          ),
                          Shadow(
                            color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                            offset: const Offset(3, 3),
                          ),
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(4, 4),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STAR!',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 66,
                        fontWeight: FontWeight.bold,
                        height: 0.8,
                        color: Colors.white,
                        letterSpacing: 0.0,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF2E5BFF).withValues(alpha: 0.8),
                            offset: const Offset(1.5, 1.5),
                          ),
                          Shadow(
                            color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                            offset: const Offset(3, 3),
                          ),
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(4, 4),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
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
