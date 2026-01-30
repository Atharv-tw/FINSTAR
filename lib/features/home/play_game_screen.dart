import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../core/motion_tokens.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/game_coin_counter.dart';
import '../../shared/widgets/streak_and_tips_section.dart';

/// Play game screen with STACKED CARDS hero interface (Spec 2.1)
class PlayGameScreen extends ConsumerStatefulWidget {
  const PlayGameScreen({super.key});

  @override
  ConsumerState<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends ConsumerState<PlayGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadController;
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late ScrollController _scrollController;

  double _scrollOffset = 0;

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
    _glowController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final user = userProfileAsync.asData?.value;
    final currentXp = user?.xp ?? 0;
    final xpForNextLevel = user?.xpForNextLevel ?? 1000;
    final coins = user?.coins ?? 0;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Hero at constant 55% height
    final heroHeightPercent = 0.55;
    final heroHeight = (screenHeight * heroHeightPercent).clamp(100.0, 480.0);

    return Scaffold(
      body: Stack(
        children: [
          // Custom Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // 50% opacity
              child: Image.asset(
                'assets/images/screenshot_2026_01_20_1_05_57_pm.png',
                fit: BoxFit.cover, // Ensures the image covers the entire background
              ),
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
              const SliverToBoxAdapter(
                child: SizedBox(height: 225),
              ),
            ],
          ),

          // Sticky header
          _buildStickyHeader(coins),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(int coins) {
    final topInset = MediaQuery.of(context).padding.top;
    const headerHeight = 52.0;
    const counterScale = 0.9;
    const shopIconSize = 38.0;
    return AnimatedContainer(
      duration: MotionTokens.medium,
      height: topInset + headerHeight,
      padding: EdgeInsets.only(left: 24, right: 24, top: topInset),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gaming-style coin counter (left side)
          Transform.scale(
            scale: counterScale,
            alignment: Alignment.centerLeft,
            child: GameCoinCounter(
              coins: coins,
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coin shop coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              showPlusButton: false,
            ),
          ),
          // Shop icon button (right side)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/shop');
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primaryStart.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SizedBox(
                width: shopIconSize,
                height: shopIconSize,
                child: Image.asset(
                  'assets/icons/shop_arcade.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.storefront_outlined,
                      color: DesignTokens.primaryEnd,
                      size: 22,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(double height) {
    // Parallax: scale 1.0 → 0.4, blur 0 → 10px, translateY 0 → -120px

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
            top: 97,
            left: 24,
            right: 24,
            child: _buildLevelProgressBar(),
          ),

          // Streak and Tips Section right below level progress
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: StreakAndTipsSection(
              streakDays: ref.watch(userProfileProvider).asData?.value?.streakDays ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar() {
    final user = ref.watch(userProfileProvider).asData?.value;
    final currentXp = user?.xp ?? 0;
    final xpForNextLevel = user?.xpForNextLevel ?? 1000;
    final levelProgress = xpForNextLevel == 0 ? 0.0 : currentXp / xpForNextLevel;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
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
                      padding: const EdgeInsets.all(12), // Reduced padding
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
                          BoxShadow(
                            color: DesignTokens.primaryStart.withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 1,
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
                                '$currentXp / $xpForNextLevel XP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Increased spacing
                          // Progress bar with star
                          SizedBox(
                            height: 24, // Increased height for the star
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: levelProgress),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutQuart,
                              builder: (context, value, child) {
                                return Stack(
                                  clipBehavior: Clip.none, // Allow star to overflow
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    // Background bar
                                    Container(
                                      height: 12, // Bar height
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    // Progress bar with glow
                                    Container(
                                      height: 12, // Bar height
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: DesignTokens.primaryStart
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: value,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  DesignTokens.primaryStart,
                                                  DesignTokens.primaryEnd
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Star slider
                                    Positioned(
                                      left: (barWidth * value) - 24, // Position star at the end of progress
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 24, // Increased size to make it more prominent
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
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
      },
    );
  }

  Widget _buildCardStackZone(double screenHeight, double screenWidth) {
    final cards = [
      _CardData(
        title: 'LIFE SWIPE',
        subtitle: '',
        description: '',
        icon: Icons.swipe_rounded,
        gradientColors: [const Color(0xFFE1C1C6), const Color(0xFFE1C1C6)],
        route: '/game/life-swipe',
      ),
      _CardData(
        title: 'BUDGET BLITZ',
        subtitle: '',
        description: '',
        icon: Icons.bolt_rounded,
        gradientColors: [const Color(0xFFF6EDA3), const Color(0xFFF6EDA3)],
        route: '/game/budget-blitz',
      ),
      _CardData(
        title: 'MARKET EXPLORER',
        subtitle: '',
        description: '',
        icon: Icons.trending_up_rounded,
        gradientColors: [const Color(0xFF94B8C9), const Color(0xFF94B8C9)],
        route: '/game/market-explorer',
      ),
      _CardData(
        title: 'QUIZ BATTLE',
        subtitle: '',
        description: '',
        icon: Icons.quiz_rounded,
        gradientColors: [const Color(0xFF829672), const Color(0xFF829672)],
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
    final collapsedHeight =
        cardHeight + (cards.length - 1) * 40.0; // One full card + 40px per additional card
    final unfoldedHeight =
        cards.length * (cardHeight + 20.0); // All cards with 20px gap
    final stackHeight =
        collapsedHeight + (unfoldProgress * (unfoldedHeight - collapsedHeight));

    return Transform.translate(
      offset: const Offset(0, -47),
      child: Container(
        padding: const EdgeInsets.only(top: 0, bottom: 24),
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
              final collapsedTop = index * 70.0; // Show 70px of each card when stacked
              final unfoldedTop = index * (cardHeight + 80.0); // Full card + gap
              final currentTop =
                  collapsedTop + (unfoldProgress * (unfoldedTop - collapsedTop));

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
                  unfoldProgress: unfoldProgress,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({
    required _CardData card,
    required int index,
    required double screenHeight,
    required double unfoldProgress,
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
            if (card.title == 'LIFE SWIPE') {
              context.push('/game/life-swipe/tutorial');
            } else if (card.title == 'MARKET EXPLORER') {
              context.push('/game/market-explorer'); // Navigate to the splash screen
            } else {
              context.push(card.route);
            }
          },
          child: SizedBox(
            height: screenHeight * 0.7, // Full card size (70% of screen height)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40), // Playing card style rounded edges
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Layer
                  BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                    child: Container(
                      decoration: BoxDecoration(
                        color: card.gradientColors[0].withValues(alpha: 0.7),
                      ),
                    ),
                  ),

                  // 2. Border & Outer Glow (Applied to both)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        // Only add outer glow if no image (images have their own visual weight)
                        BoxShadow(
                          blurRadius: 24,
                          color:
                              card.gradientColors[0].withValues(alpha: glowOpacity),
                        ),
                      ],
                    ),
                  ),

                  // 3. Content Layer
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildCollapsedCardContent(card, unfoldProgress),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedCardContent(_CardData card, double unfoldProgress) {
    // Market Explorer has smaller final size
    double animatedFontSize = card.title == 'MARKET EXPLORER'
        ? 24 + (unfoldProgress * 6)  // 24 to 30
        : 24 + (unfoldProgress * 12); // Default: 24 to 36
    double animatedIconSize = 24 + (unfoldProgress * 12); // Default: 24 to 36
    double iconSpacing = 8.0; // Default spacing
    Offset contentOffset = Offset.zero; // Default offset

    if (card.title == 'LIFE SWIPE') {
      return _LifeSwipeCardContent(
        card: card,
        unfoldProgress: unfoldProgress,
        glowController: _glowController, // Pass the glow controller
      );
    } else if (card.title == 'BUDGET BLITZ') {
      return _BudgetBlitzCardContent(
        card: card,
        unfoldProgress: unfoldProgress,
      );
    }

    final Alignment animatedAlignment =
        Alignment.lerp(Alignment.topLeft, Alignment.topCenter, unfoldProgress)!;

    return Align(
      alignment: animatedAlignment,
      child: Transform.translate(
        offset: contentOffset,
        child: Row(
          mainAxisSize: MainAxisSize.min, // To keep the Row compact
          children: [
            Icon(
              card.icon,
              size: animatedIconSize,
              color: DesignTokens.textPrimary,
            ),
            SizedBox(width: iconSpacing),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                card.title,
                style: GoogleFonts.luckiestGuy(
                  fontSize: animatedFontSize,
                  color: DesignTokens.textPrimary,
                  height: 1.1,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Grid pattern painter for hero overlay
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
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

// New Widget for Life Swipe Card Content
class _LifeSwipeCardContent extends StatefulWidget {
  final _CardData card;
  final double unfoldProgress;
  final AnimationController glowController;

  const _LifeSwipeCardContent({
    required this.card,
    required this.unfoldProgress,
    required this.glowController,
  });

  @override
  State<_LifeSwipeCardContent> createState() => _LifeSwipeCardContentState();
}

class _LifeSwipeCardContentState extends State<_LifeSwipeCardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Matches CSS animation: swipe 2s infinite ease-in-out;

    _swipeAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(
        parent: _swipeAnimationController,
        curve: Curves.easeInOut, // Corresponds to CSS ease-in-out
      ),
    );
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double animatedFontSize = 24 + (widget.unfoldProgress * 12); // Default: 24 to 36
    double animatedIconSize = 24 + (widget.unfoldProgress * 12); // Default: 24 to 36
    double iconSpacing = 8.0; // Default spacing
    Offset contentOffset = Offset.zero; // Default offset

    final Alignment animatedAlignment =
        Alignment.lerp(Alignment.topLeft, Alignment.topCenter, widget.unfoldProgress)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: animatedAlignment,
          child: Transform.translate(
            offset: contentOffset,
            child: Row(
              mainAxisSize: MainAxisSize.min, // To keep the Row compact
              children: [
                Icon(
                  widget.card.icon,
                  size: animatedIconSize,
                  color: DesignTokens.textPrimary,
                ),
                SizedBox(width: iconSpacing),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.card.title,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: animatedFontSize,
                      color: DesignTokens.textPrimary,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Card Area
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDDDDDD),
                width: 2,
              ), // Using solid border instead of dashed for simplicity
            ),
            child: Center(
              child: SizedBox(
                width: 390,
                height: 390,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/lifeswipewidget.jpeg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE53935), width: 2),
              ),
              child: const Icon(
                Icons.close,
                size: 28,
                color: Color(0xFFE53935),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF43A047), width: 2),
              ),
              child: const Icon(
                Icons.favorite,
                size: 28,
                color: Color(0xFF43A047),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MarketExplorerCardContent extends StatelessWidget {
  const _MarketExplorerCardContent({
    required this.card,
    required this.unfoldProgress,
  });

  final _CardData card;
  final double unfoldProgress;

  @override
  Widget build(BuildContext context) {
    // Animation parameters for the heading
    // Start: small text at top-left, single line "MARKET EXPLORER"
    // End: larger text centered inside calculator screen, two lines "MARKET" / "EXPLORER"
    
    // Font size: 24 -> 20 (shrinks as it moves into the screen)
    final double animatedFontSize = 24 - (unfoldProgress * 4);
    
    // Icon size: shrinks and fades as we animate into the screen
    final double animatedIconSize = 24 * (1 - unfoldProgress);
    final double iconOpacity = 1 - unfoldProgress;
    
    // The calculator screen is approximately at 8-22% from top of the image
    // Target center for text: ~16% from top
    // Card padding is 24px, so we need to calculate the offset relative to the padded area
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final cardWidth = constraints.maxWidth;
        
        // Calculate target Y position (inside calculator screen)
        // Calculator screen center is approximately 16% from top of the image area
        // The image fills from top of the card (after we remove the old header space)
        final double targetY = cardHeight * 0.10; // 10% from top
        
        // Animate vertical position: start at 0 (top), end inside calculator screen
        final double animatedY = unfoldProgress * targetY;
        
        // Animate horizontal position: start at left edge, end at center
        final double targetX = (cardWidth - 150) / 2; // Approximate center for text block
        final double animatedX = unfoldProgress * targetX;
        
        return Stack(
          children: [
            // Calculator image - fills the entire card
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/marketexplorercalc.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Animated text overlay
            Positioned(
              left: animatedX,
              top: animatedY,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon fades out as animation progresses
                  if (iconOpacity > 0.01)
                    Opacity(
                      opacity: iconOpacity,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          card.icon,
                          size: animatedIconSize,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  
                  // Text transitions from single line to two lines
                  _buildAnimatedText(animatedFontSize),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildAnimatedText(double fontSize) {
    // Crossfade between single line and two line versions
    if (unfoldProgress < 0.5) {
      // First half: show single line, fading out
      final double opacity = 1 - (unfoldProgress * 2);
      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Text(
          'MARKET EXPLORER',
          style: GoogleFonts.luckiestGuy(
            fontSize: fontSize,
            color: DesignTokens.textPrimary,
            height: 1.1,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      // Second half: show two lines, fading in
      final double opacity = (unfoldProgress - 0.5) * 2;
      const double twoLineFontSize = 34.0; // Larger size for two-line format
      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MARKET',
              style: GoogleFonts.luckiestGuy(
                fontSize: twoLineFontSize,
                color: const Color(0xFF2D5A4A), // Darker color for visibility on screen
                height: 1.1,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'EXPLORER',
              style: GoogleFonts.luckiestGuy(
                fontSize: twoLineFontSize,
                color: const Color(0xFF2D5A4A), // Darker color for visibility on screen
                height: 1.1,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Quiz Battle card content with full image cover
class _QuizBattleCardContent extends StatelessWidget {
  const _QuizBattleCardContent({
    required this.card,
    required this.unfoldProgress,
  });

  final _CardData card;
  final double unfoldProgress;

  @override
  Widget build(BuildContext context) {
    // Font size: starts at 32, grows to 36
    final double animatedFontSize = 32 + (unfoldProgress * 4);
    
    // Icon size: shrinks and fades as we animate
    final double animatedIconSize = 28 * (1 - unfoldProgress * 0.5);
    final double iconOpacity = 1 - (unfoldProgress * 0.8);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight;
        final cardWidth = constraints.maxWidth;
        
        // Start a bit lower (20px down), animate to 8% from top
        final double startY = 20.0;
        final double targetY = cardHeight * 0.08;
        final double animatedY = startY + (unfoldProgress * (targetY - startY));
        
        final double targetX = (cardWidth - 200) / 2;
        final double animatedX = unfoldProgress * targetX;
        
        return Stack(
          children: [
            // Quiz Battle image - fills the entire card
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/quizbattle.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Animated text overlay
            Positioned(
              left: animatedX,
              top: animatedY,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon fades out as animation progresses
                  if (iconOpacity > 0.01)
                    Opacity(
                      opacity: iconOpacity,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          card.icon,
                          size: animatedIconSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  // Title text
                  Text(
                    'QUIZ BATTLE',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: animatedFontSize,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// New Widget for Budget Blitz Game Content
class _BudgetBlitzCardContent extends StatelessWidget {
  const _BudgetBlitzCardContent({
    required this.card,
    required this.unfoldProgress,
  });

  final _CardData card;
  final double unfoldProgress;

  @override
  Widget build(BuildContext context) {
    double animatedFontSize = 24 + (unfoldProgress * 12); // Default: 24 to 36
    double animatedIconSize = 24 + (unfoldProgress * 12); // Default: 24 to 36
    double iconSpacing = 8.0; // Default spacing
    Offset contentOffset = Offset.zero; // Default offset

    final Alignment animatedAlignment =
        Alignment.lerp(Alignment.topLeft, Alignment.topCenter, unfoldProgress)!;

    return Column(
      children: [
        Align(
          alignment: animatedAlignment,
          child: Transform.translate(
            offset: contentOffset,
            child: Row(
              mainAxisSize: MainAxisSize.min, // To keep the Row compact
              children: [
                Icon(
                  card.icon,
                  size: animatedIconSize,
                  color: DesignTokens.textPrimary,
                ),
                SizedBox(width: iconSpacing),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    card.title,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: animatedFontSize,
                      color: DesignTokens.textPrimary,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Expanded(child: _GameConsole(child: _BudgetBlitzGame())),
      ],
    );
  }
}

class _BudgetBlitzGame extends StatefulWidget {
  const _BudgetBlitzGame({super.key});

  @override
  State<_BudgetBlitzGame> createState() => _BudgetBlitzGameState();
}

class _BudgetBlitzGameState extends State<_BudgetBlitzGame> {
  double cartX = 0.0;
  double itemX = 0.0;
  double itemY = -1.0;

  final Random random = Random();
  late Timer timer;

  final List<IconData> items = [
    Icons.shopping_bag,
    Icons.apple,
    Icons.attach_money,
  ];
  IconData currentItem = Icons.apple;

  @override
  void initState() {
    super.initState();
    spawnItem();

    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        itemY += 0.02;

        if (itemY > 1.1) {
          spawnItem();
        }

        // collision check
        if ((itemY > 0.8) && (cartX - itemX).abs() < 0.2) {
          spawnItem();
        }
      });
    });
  }

  void spawnItem() {
    itemX = random.nextDouble() * 2 - 1;
    itemY = -1.2;
    currentItem = items[random.nextInt(items.length)];
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          cartX += details.delta.dx / 150;
          cartX = cartX.clamp(-1.0, 1.0);
        });
      },
      child: Stack(
        children: [
          // Falling item
          Align(
            alignment: Alignment(itemX, itemY),
            child: Icon(
              currentItem,
              size: 26,
              color: Colors.white,
            ),
          ),

          // Shopping cart
          Align(
            alignment: Alignment(cartX, 0.9),
            child: const Icon(
              Icons.shopping_cart,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameConsole extends StatelessWidget {
  const _GameConsole({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20), // Changed padding
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDA3), // Console color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Screen
          Expanded(
            flex: 3, // Increased flex for bigger screen
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade800, width: 12), // Wider border
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: child,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Controls
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
              children: [
                // D-pad
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFF0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 25,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFF0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Added a SizedBox for spacing after D-pad
                const SizedBox(width: 30), // Increased gap

                // Slanting buttons
                Row(
                  children: [
                    Transform.rotate(
                      angle: -pi / 6,
                      child: Container(
                        width: 40, // Made smaller
                        height: 20, // Made smaller
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFF0),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Transform.rotate(
                      angle: -pi / 6,
                      child: Container(
                        width: 40, // Made smaller
                        height: 20, // Made smaller
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFF0),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Added a SizedBox for spacing before A/B buttons
                const SizedBox(width: 30), // Increased gap

                // A and B Buttons
                Transform.translate( // Wrap Column with Transform.translate
                  offset: const Offset(-2.0, 0), // Shift left by 2 pixels
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0), // More diagonal
                        child: _buildConsoleButton('A'), // Label will be removed inside _buildConsoleButton
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 10.0), // More diagonal
                        child: _buildConsoleButton('B'), // Label will be removed inside _buildConsoleButton
                      ),
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

  Widget _buildConsoleButton(String label) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFF0),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
