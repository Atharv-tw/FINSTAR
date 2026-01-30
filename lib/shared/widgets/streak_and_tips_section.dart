import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Finance tips for the carousel
const List<String> _financeTips = [
  "💡 Diversifying your portfolio reduces risk in investments",
  "💰 The earlier you start investing, the more time compound interest works for you",
  "📊 Never invest more than you can afford to lose",
  "🏦 An emergency fund should cover 3-6 months of expenses",
  "📈 Dollar-cost averaging helps reduce timing risk in volatile markets",
  "🎯 Set specific financial goals with deadlines to stay motivated",
  "💳 Paying off high-interest debt should be a priority",
  "📱 Track your spending to find areas where you can save",
  "🔒 Protect your wealth with adequate insurance coverage",
  "🌱 Start small but be consistent - habits beat intensity",
];

/// Stacked widget showing streak display and rotating tips carousel
class StreakAndTipsSection extends StatefulWidget {
  final int streakDays;

  const StreakAndTipsSection({
    super.key,
    this.streakDays = 0,
  });

  @override
  State<StreakAndTipsSection> createState() => _StreakAndTipsSectionState();
}

class _StreakAndTipsSectionState extends State<StreakAndTipsSection>
    with TickerProviderStateMixin {
  late AnimationController _fireGlowController;
  late PageController _tipsPageController;
  late Timer _autoScrollTimer;
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();

    // Fire glow animation
    _fireGlowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Tips carousel
    _tipsPageController = PageController();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _financeTips.length;
        });
        _tipsPageController.animateToPage(
          _currentTipIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _fireGlowController.dispose();
    _tipsPageController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Streak Display
          _buildStreakRow(),
          const SizedBox(height: 12),
          // Tips Carousel
          _buildTipsCarousel(),
        ],
      ),
    );
  }

  Widget _buildStreakRow() {
    return AnimatedBuilder(
      animation: _fireGlowController,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_fireGlowController.value * 0.4);
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B4A).withValues(alpha: 0.25),
                    const Color(0xFFFF8E53).withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF6B4A).withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B4A).withValues(alpha: glowIntensity),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fire icon with glow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B4A), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B4A).withValues(alpha: glowIntensity),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Streak text
                  Text(
                    '${widget.streakDays} Day Streak!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Keep it going! 🔥',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipsCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A90E2).withValues(alpha: 0.5),
                const Color(0xFF6366F1).withValues(alpha: 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Tips PageView
              SizedBox(
                height: 40,
                child: PageView.builder(
                  controller: _tipsPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentTipIndex = index;
                    });
                  },
                  itemCount: _financeTips.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        _financeTips[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_financeTips.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentTipIndex == index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentTipIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
