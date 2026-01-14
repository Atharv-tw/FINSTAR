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
                    // Scrollable Top Bar
                    StreakTitleBar(
                      streakDays: userData.streakDays,
                      userPhotoUrl: userData.avatarUrl,
                      currentXp: userData.xp,
                      nextLevelXp: userData.level * 1000,
                    ),

                    const SizedBox(height: 176.5),

                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Section with Panda
                          _buildProgressWithPandaSection(screenWidth, userData),

                          const SizedBox(height: 33),

                          // Featured Hero Card
                          FeaturedHeroCard(
                            onTap: () => context.go('/game'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Section Header: LEARNING MODULES
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: DesignTokens.primarySolid,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'LEARNING MODULES',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: DesignTokens.textPrimary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Divider(
                            color: DesignTokens.textPrimary.withValues(alpha: 0.08),
                            thickness: 1,
                            height: 1,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Learning Categories - Full Width
                    FinanceTilesSection(scrollController: _scrollController),

                    const SizedBox(height: 120), // Bottom spacing for nav bar
                  ],
                ),
              );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: DesignTokens.primarySolid),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: DesignTokens.error),
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
            // Transparent Box Wrapper with Heavy Shadow
            Positioned(
              top: -165,
              bottom: -10,
              left: -10,
              right: -10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01), // Transparent but hittable
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

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
                      color: DesignTokens.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DesignTokens.textDisabled.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
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

                        // Progress bars - POP UP animation matching panda
                        Expanded(
                          child: Transform.translate(
                            offset: Offset(0, _pandaSlideAnimation.value),
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
                                        color: DesignTokens.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${userData.xp} / $xpForNextLevel XP',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: DesignTokens.textSecondary,
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
                                        color: DesignTokens.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${(studyProgress * 100).toInt()}%',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: DesignTokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildProgressBar(studyProgress, DesignTokens.secondaryGradient),
                              ],
                            ),
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
              right: -26,
              top: -186,
              child: Transform.translate(
                offset: Offset(0, _pandaSlideAnimation.value),
                child: FadeTransition(
                  opacity: _pandaController,
                  child: Transform.scale(
                    scale: breathingScale * 0.88,
                    child: Image.asset(
                      'assets/images/Screenshot_2026-01-11_at_2.43.01_PM-removebg-preview-2.png',
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
              top: -125, // Moved down by 40 pixels
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
                        color: DesignTokens.textPrimary,
                        letterSpacing: 3.5, // Increased horizontally
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STAR!',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 66,
                        fontWeight: FontWeight.bold,
                        height: 0.8,
                        color: DesignTokens.textPrimary,
                        letterSpacing: 0.0,
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
                color: DesignTokens.accentSolid.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Progress bar with glow
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
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
