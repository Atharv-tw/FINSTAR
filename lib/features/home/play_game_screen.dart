import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';
import '../../shared/widgets/xp_ring.dart';
import '../../shared/widgets/coin_pill.dart';

/// Play game screen with STACKED CARDS hero interface (Spec 2.1)
class PlayGameScreen extends StatefulWidget {
  const PlayGameScreen({super.key});

  @override
  State<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends State<PlayGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadController;
  late AnimationController _breathingController;
  late AnimationController _hueController;
  late AnimationController _glowController;
  late ScrollController _scrollController;

  double _scrollOffset = 0;

  // Mock user data
  final int _userLevel = 5;
  final int _currentXp = 750;
  final int _xpForNextLevel = 1000;
  final int _coins = 340;

  @override
  void initState() {
    super.initState();

    _loadController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Mascot breathing animation (2s loop)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Background hue shift (30s loop)
    _hueController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);

    // Card glow pulse (3s loop)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Scroll listener with throttling
    _scrollController = ScrollController()
      ..addListener(_onScroll);

    // Trigger load animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadController.forward();
    });
  }

  void _onScroll() {
    final newOffset = _scrollController.offset;
    if ((newOffset - _scrollOffset).abs() > 1.0) {
      setState(() {
        _scrollOffset = newOffset;
      });
    }
  }

  @override
  void dispose() {
    _loadController.dispose();
    _breathingController.dispose();
    _hueController.dispose();
    _glowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Hero at constant 55% height
    final heroHeightPercent = 0.55;
    final heroHeight = (screenHeight * heroHeightPercent).clamp(100.0, 480.0);

    return Scaffold(
      body: Stack(
        children: [
          // Darker vibrant background gradient (same colors, darker)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _hueController,
              builder: (context, child) {
                final hueShift = (_hueController.value - 0.5) * 16; // ±8°
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF8B6A50), // Darker peachy orange
                        Color(0xFF8B5065), // Darker pink
                        Color(0xFF6A508B), // Darker purple
                        Color(0xFF50658B), // Darker blue
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),

          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero section
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuart,
                  height: heroHeight,
                  child: _buildHeroSection(heroHeight),
                ),
              ),

              // Card stack zone
              SliverToBoxAdapter(
                child: _buildCardStackZone(screenHeight, screenWidth),
              ),

              // Extra space to enable scrolling for card unfold animation
              SliverToBoxAdapter(
                child: SizedBox(height: 600),
              ),
            ],
          ),

          // Sticky header
          _buildStickyHeader(),
        ],
      ),
    );
  }

  Widget _buildStickyHeader() {
    final shouldBlur = _scrollOffset > 100;

    return AnimatedContainer(
      duration: MotionTokens.medium,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: shouldBlur
            ? const Color(0xFF0B0B0D).withValues(alpha: 0.8)
            : Colors.transparent,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // XP Ring - 48px
            XpRing(
              currentXp: _currentXp,
              xpForNextLevel: _xpForNextLevel,
              level: _userLevel,
              size: 48,
              levelTextColor: Colors.black,
            ),

            // Coin Pill and Shop Button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CoinPill(coins: _coins, height: 40),
                const SizedBox(width: 12),
                // Shop icon button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DesignTokens.accentStart, DesignTokens.accentEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: DesignTokens.accentStart.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Navigate to shop screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shop coming soon!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(double height) {
    // Parallax: scale 1.0 → 0.4, blur 0 → 10px, translateY 0 → -120px
    final parallaxProgress = (_scrollOffset / 400).clamp(0.0, 1.0);
    final mascotScale = 1.0 - (parallaxProgress * 0.6); // 1.0 → 0.4
    final mascotBlur = parallaxProgress * 10; // 0 → 10px
    final mascotTranslateY = -parallaxProgress * 120; // 0 → -120px

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Geometric grid overlay
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(),
            ),
          ),

          // Level Progress Bar above panda
          Positioned(
            top: 120,
            left: 8,
            right: 8,
            child: _buildLevelProgressBar(),
          ),

          // 3D Mascot with parallax and breathing - positioned to sit on cards
          Positioned(
            bottom: -178, // Position to overlap with card stack
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, mascotTranslateY),
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    final breathingScale = 1.0 + (_breathingController.value * 0.02);
                    return Transform.scale(
                      scale: mascotScale * breathingScale,
                      child: child,
                    );
                  },
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Transform.rotate(
                            angle: (1.0 - value) * -0.087, // -5° to 0°
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: mascotBlur,
                                sigmaY: mascotBlur,
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Transform.scale(
                        scale: 1.26, // Zoom the panda
                        child: Image.asset(
                          'assets/images/panda1.png',
                          width: 500,
                          height: 500,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar() {
    final levelProgress = _currentXp / _xpForNextLevel;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, (1 - animValue) * -20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0D).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Level progress label and XP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level Progress',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          Text(
                            '$_currentXp / $_xpForNextLevel XP',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: levelProgress),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Stack(
                            children: [
                              // Background bar
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
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
                                      color: DesignTokens.primaryStart.withValues(alpha: 0.4),
                                      blurRadius: 8,
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
                                        gradient: LinearGradient(
                                          colors: [DesignTokens.primaryStart, DesignTokens.primaryEnd],
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardStackZone(double screenHeight, double screenWidth) {
    final cards = [
      _CardData(
        title: 'Life Swipe',
        subtitle: 'Budget your way through life',
        description: '💳 Swipe right on smart choices! Every decision shapes your fortune.\n\nNavigate real-life scenarios—from buying coffee to choosing a career. Swipe left to save, right to spend. Can you balance fun and financial freedom?',
        icon: Icons.swipe_rounded,
        gradientColors: [DesignTokens.secondaryStart, DesignTokens.secondaryEnd],
        route: '/game/life-swipe',
      ),
      _CardData(
        title: 'Market Explorer',
        subtitle: 'Invest and grow your wealth',
        description: '📈 Build your empire! Watch your portfolio soar or crash—you decide!\n\nDive into stocks, bonds, and crypto. Learn to diversify, manage risk, and time the market. Will you play it safe or go all-in on that hot tech stock?',
        icon: Icons.trending_up_rounded,
        gradientColors: [DesignTokens.accentStart, DesignTokens.accentEnd],
        route: '/game/market-explorer',
      ),
      _CardData(
        title: 'Budget Blitz',
        subtitle: 'Master your monthly money',
        description: '⚡ Race the clock to balance your budget! Allocate income, pay bills, and save before time runs out.\n\nJuggle rent, groceries, entertainment, and surprise expenses. Can you end the month in the green? Fast-paced financial decisions await!',
        icon: Icons.bolt_rounded,
        gradientColors: [const Color(0xFFFF6B9D), const Color(0xFFC06C84)],
        route: '/game/budget-blitz',
      ),
      _CardData(
        title: 'Quiz Battle',
        subtitle: 'Test your financial knowledge',
        description: '⚡ Lightning-fast questions, epic rewards! Can you outsmart the market?\n\nRace against the clock to answer financial trivia. Each correct answer boosts your XP and unlocks new challenges. Think you know money? Prove it!',
        icon: Icons.quiz_rounded,
        gradientColors: [DesignTokens.primaryStart, DesignTokens.primaryEnd],
        route: '/game/quiz-battle',
      ),
    ];

    // Card unfolding: calculate how much to unfold based on scroll
    // Start unfolding immediately, fully unfolded at 300px
    final unfoldProgress = (_scrollOffset / 300).clamp(0.0, 1.0);

    // Keep the order: Play Games should be first when unfolded (it's visually on top of stack)
    final displayCards = cards;

    // Calculate stack height based on unfold progress
    // Collapsed: full card height + 40px visible per additional card
    // Unfolded: all cards fully visible with gaps
    final cardHeight = screenHeight * 0.7;
    final collapsedHeight = cardHeight + (cards.length - 1) * 40.0; // One full card + 40px per additional card
    final unfoldedHeight = cards.length * (cardHeight + 20.0); // All cards with 20px gap
    final stackHeight = collapsedHeight + (unfoldProgress * (unfoldedHeight - collapsedHeight));

    return Container(
      padding: const EdgeInsets.only(top: 80, bottom: 24),
      child: SizedBox(
        height: stackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: displayCards.asMap().entries.map((entry) {
          final index = entry.key; // 0 is Play Games (first), 3 is Friends (last)
          final card = entry.value;

          // When collapsed (unfoldProgress = 0): Cards stacked with only 40px visible each
          // When unfolded (unfoldProgress = 1): Cards fully separated with 20px gap

          // Calculate vertical position
          // Collapsed: cards overlap, showing 40px of each card
          // Unfolded: full card height + 20px gap
          final collapsedTop = index * 40.0; // Show 40px of each card when stacked
          final unfoldedTop = index * (cardHeight + 20.0); // Full card + gap
          final currentTop = collapsedTop + (unfoldProgress * (unfoldedTop - collapsedTop));

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            top: currentTop,
            left: 13,
            right: 13,
            child: _buildGlassmorphicCard(
              card: card,
              index: index,
              screenHeight: screenHeight,
            ),
          );
        }).toList(),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({
    required _CardData card,
    required int index,
    required double screenHeight,
  }) {
    // Progressive blur: +4px per card
    final blurAmount = 24.0 + (index * 4.0);

    // Animated glow pulse (0.3 → 0.5 → 0.3)
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.3 + (_glowController.value * 0.2); // 0.3 to 0.5

        return GestureDetector(
          onTap: () {
            // Navigate to game
            HapticFeedback.mediumImpact();
            context.push(card.route);
          },
          child: Container(
            height: screenHeight * 0.7, // Full card size (70% of screen height)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40), // Playing card style rounded edges
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0D).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 12 + (index * 4)),
                        blurRadius: 24 + (index * 8),
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                      BoxShadow(
                        blurRadius: 24,
                        color: card.gradientColors[0].withValues(alpha: glowOpacity),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _buildCollapsedCardContent(card),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedCardContent(_CardData card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: Icon badge with 16px offset from top-left
        Padding(
          padding: const EdgeInsets.only(left: 0, top: 0), // Already has 24px from container padding
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: card.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              card.icon,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Title - Poppins Bold 24px
        Text(
          card.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle - Inter Regular 14px
        if (card.subtitle.isNotEmpty)
          Text(
            card.subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),

        if (card.subtitle.isNotEmpty) const SizedBox(height: 12),

        // Description - Fun and catchy info
        if (card.description.isNotEmpty)
          Text(
            card.description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
      ],
    );
  }

}

/// Grid pattern painter for hero overlay
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String route;

  _CardData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.route,
  });
}
