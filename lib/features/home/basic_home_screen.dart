import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';
import '../../shared/widgets/xp_ring.dart';
import '../../shared/widgets/coin_pill.dart';
import '../../shared/widgets/blur_dock.dart';

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
  late AnimationController _tilesController;
  late AnimationController _breathingController;

  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _progressScaleAnimation;
  late Animation<double> _pandaSlideAnimation;
  late Animation<double> _tilesStaggerAnimation;

  // User data
  final String _userName = "Star";
  final int _userLevel = 5;
  final int _currentXp = 750;
  final int _xpForNextLevel = 1000;
  final int _coins = 340;
  final double _studyProgress = 0.65; // 65% study progress

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

    // Tiles animation
    _tilesController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tilesStaggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tilesController, curve: Curves.easeOutQuart),
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
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _tilesController.forward();
      });
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _progressController.dispose();
    _pandaController.dispose();
    _tilesController.dispose();
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
          // Dark background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF000000),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Greeting Section
                    _buildGreetingSection(),

                    const SizedBox(height: 24),

                    // Progress Section
                    _buildProgressSection(),

                    const SizedBox(height: 24),

                    // Panda Mascot Section
                    _buildPandaSection(screenWidth),

                    const SizedBox(height: 32),

                    // Learning Categories
                    _buildCategoriesSection(),

                    const SizedBox(height: 120), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlurDock(
              items: const [
                NavItem(
                    icon: Icons.home_rounded, label: 'Home', route: '/'),
                NavItem(
                    icon: Icons.videogame_asset_rounded,
                    label: 'Play Games',
                    route: '/game'),
                NavItem(
                    icon: Icons.leaderboard_rounded,
                    label: 'Leaderboard',
                    route: '/rewards'),
                NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    route: '/profile'),
              ],
              selectedIndex: 0,
              showFab: false,
              onItemTap: (index) {
                final routes = ['/', '/game', '/rewards', '/profile'];
                context.go(routes[index]);
              },
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Greeting text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Coin pill
                CoinPill(coins: _coins, height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Transform.scale(
          scale: _progressScaleAnimation.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
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
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '$_currentXp / $_xpForNextLevel XP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.5),
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
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '${(_studyProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.5),
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
        );
      },
    );
  }

  Widget _buildProgressBar(double progress, LinearGradient gradient) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPandaSection(double screenWidth) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pandaController, _breathingController]),
      builder: (context, child) {
        final breathingScale = 1.0 + (_breathingController.value * 0.03);
        return Transform.translate(
          offset: Offset(0, _pandaSlideAnimation.value),
          child: FadeTransition(
            opacity: _pandaController,
            child: Center(
              child: Transform.scale(
                scale: breathingScale,
                child: Image.asset(
                  'assets/images/pandahome.png',
                  width: screenWidth * 0.5,
                  height: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        AnimatedBuilder(
          animation: _tilesController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _tilesStaggerAnimation,
              child: const Text(
                'Start Learning',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Categories grid
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 16) / 2;
            return Column(
              children: [
                // First row
                Row(
                  children: [
                    _buildCategoryTile(
                      0,
                      'Money\nBasics',
                      Icons.account_balance_wallet_rounded,
                      DesignTokens.primaryGradient,
                      tileWidth,
                    ),
                    const SizedBox(width: 16),
                    _buildCategoryTile(
                      1,
                      'Earning &\nCareer',
                      Icons.work_rounded,
                      DesignTokens.secondaryGradient,
                      tileWidth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row
                Row(
                  children: [
                    _buildCategoryTile(
                      2,
                      'Banking &\nInstitutes',
                      Icons.account_balance_rounded,
                      DesignTokens.accentGradient,
                      tileWidth,
                    ),
                    const SizedBox(width: 16),
                    _buildCategoryTile(
                      3,
                      'Investing &\nGrowth',
                      Icons.trending_up_rounded,
                      const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFC06C84)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      tileWidth,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryTile(
    int index,
    String title,
    IconData icon,
    LinearGradient gradient,
    double width,
  ) {
    final delay = index * 0.1;
    return AnimatedBuilder(
      animation: _tilesController,
      builder: (context, child) {
        final staggerValue = (_tilesStaggerAnimation.value - delay).clamp(0.0, 1.0);
        return Transform.scale(
          scale: staggerValue,
          child: Opacity(
            opacity: staggerValue,
            child: SizedBox(
              width: width,
              height: width,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/learn');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors[0].withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon with gradient
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
