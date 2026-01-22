import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_tokens.dart';
import '../../services/supabase_functions_service.dart';
import '../../shared/widgets/nature_background.dart';

/// Daily Challenges Screen - Shows today's 3 challenges with progress
class DailyChallengesScreen extends ConsumerStatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  ConsumerState<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends ConsumerState<DailyChallengesScreen> {
  final SupabaseFunctionsService _supabaseService = SupabaseFunctionsService();
  List<Map<String, dynamic>> _challenges = [];
  bool _isLoading = true;
  bool _isRequestInProgress = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    if (_isRequestInProgress) {
      debugPrint('Request already in progress, skipping...');
      return;
    }

    _isRequestInProgress = true;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('Loading daily challenges...');
      final result = await _supabaseService.generateDailyChallenges();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _challenges = List<Map<String, dynamic>>.from(result['challenges'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Failed to load challenges';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      _isRequestInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nature Background matching home screen
          const NatureBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: DesignTokens.primarySolid,
                          ),
                        )
                      : _error != null
                          ? _buildErrorState()
                          : _buildChallengesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: DesignTokens.textPrimary),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Daily Challenges',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: DesignTokens.textPrimary),
            onPressed: _loadChallenges,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: DesignTokens.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load challenges',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: DesignTokens.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadChallenges,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primarySolid,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesList() {
    final completedCount = _challenges.where((c) => c['completed'] == true).length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Overview Card
          _buildProgressOverviewCard(completedCount),

          const SizedBox(height: 24),

          // Section Header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: DesignTokens.primarySolid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Today's Challenges",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Challenge Cards
          ..._challenges.asMap().entries.map((entry) {
            final index = entry.key;
            final challenge = entry.value;
            return _buildChallengeCard(challenge, index);
          }),

          const SizedBox(height: 24),

          // Tips Section
          _buildTipsSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressOverviewCard(int completedCount) {
    final totalChallenges = _challenges.length;
    final progress = totalChallenges > 0 ? completedCount / totalChallenges : 0.0;
    final allCompleted = completedCount == totalChallenges && totalChallenges > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: allCompleted
                  ? [
                      DesignTokens.success.withValues(alpha: 0.15),
                      DesignTokens.success.withValues(alpha: 0.08),
                    ]
                  : [
                      DesignTokens.primarySolid.withValues(alpha: 0.12),
                      DesignTokens.primarySolid.withValues(alpha: 0.06),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: allCompleted
                  ? DesignTokens.success.withValues(alpha: 0.3)
                  : DesignTokens.primarySolid.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Progress',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount / $totalChallenges',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: allCompleted
                          ? const LinearGradient(
                              colors: [DesignTokens.success, Color(0xFF16A34A)],
                            )
                          : DesignTokens.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (allCompleted
                                  ? DesignTokens.success
                                  : DesignTokens.primarySolid)
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        allCompleted ? '✓' : '${(progress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: allCompleted ? 28 : 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Progress Bar
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: DesignTokens.textDisabled.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: allCompleted
                            ? const LinearGradient(
                                colors: [DesignTokens.success, Color(0xFF16A34A)],
                              )
                            : DesignTokens.primaryGradient,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
              if (allCompleted) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DesignTokens.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignTokens.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'All challenges completed! Great job!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, int index) {
    final isCompleted = challenge['completed'] == true;
    final progress = challenge['progress'] ?? 0;
    final target = challenge['target'] ?? 1;
    final progressPercent = (progress / target).clamp(0.0, 1.0);
    final xpReward = challenge['xpReward'] ?? 0;
    final coinReward = challenge['coinReward'] ?? 0;
    final type = challenge['type'] ?? 'other';
    final description = challenge['description'] ?? 'Complete this challenge';

    final challengeData = _getChallengeVisualData(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCompleted
                  ? DesignTokens.success.withValues(alpha: 0.08)
                  : DesignTokens.surfaceCard.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? DesignTokens.success.withValues(alpha: 0.3)
                    : DesignTokens.textDisabled.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                                colors: [DesignTokens.success, Color(0xFF16A34A)],
                              )
                            : LinearGradient(colors: challengeData.gradientColors),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted
                                    ? DesignTokens.success
                                    : challengeData.color)
                                .withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                            : Text(
                                challengeData.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challengeData.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? DesignTokens.textTertiary
                                  : DesignTokens.textPrimary,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: DesignTokens.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DesignTokens.success, Color(0xFF16A34A)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: DesignTokens.textDisabled.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progressPercent,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: isCompleted
                                    ? const LinearGradient(
                                        colors: [DesignTokens.success, Color(0xFF16A34A)],
                                      )
                                    : LinearGradient(colors: challengeData.gradientColors),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$progress / $target',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rewards
                Row(
                  children: [
                    _buildRewardChip('+$xpReward XP', DesignTokens.primarySolid),
                    const SizedBox(width: 8),
                    _buildRewardChip('+$coinReward', const Color(0xFFD4A017), isCoins: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardChip(String text, Color color, {bool isCoins = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCoins)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.monetization_on_rounded, color: color, size: 14),
            ),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignTokens.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DesignTokens.warning.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignTokens.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('💡', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro Tip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.accentSolid,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Complete all 3 challenges daily to maximize your rewards!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: DesignTokens.textSecondary,
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

  _ChallengeVisualData _getChallengeVisualData(String type) {
    switch (type) {
      case 'playGames':
        return _ChallengeVisualData(
          title: 'Game Time',
          emoji: '🎮',
          color: const Color(0xFF7C3AED),
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
      case 'earnXp':
        return _ChallengeVisualData(
          title: 'XP Hunter',
          emoji: '⚡',
          color: DesignTokens.primarySolid,
          gradientColors: const [DesignTokens.primaryStart, DesignTokens.primaryEnd],
        );
      case 'earnCoins':
        return _ChallengeVisualData(
          title: 'Coin Collector',
          emoji: '💰',
          color: const Color(0xFFD4A017),
          gradientColors: const [Color(0xFFE6B422), Color(0xFFD4A017)],
        );
      case 'completeLesson':
        return _ChallengeVisualData(
          title: 'Knowledge Seeker',
          emoji: '📚',
          color: const Color(0xFF059669),
          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
        );
      case 'perfectScore':
        return _ChallengeVisualData(
          title: 'Perfectionist',
          emoji: '🎯',
          color: const Color(0xFFDC2626),
          gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
      case 'winQuiz':
        return _ChallengeVisualData(
          title: 'Quiz Champion',
          emoji: '🏆',
          color: const Color(0xFFD4A017),
          gradientColors: const [Color(0xFFE6B422), Color(0xFFD4A017)],
        );
      default:
        return _ChallengeVisualData(
          title: 'Challenge',
          emoji: '🎯',
          color: DesignTokens.primarySolid,
          gradientColors: const [DesignTokens.primaryStart, DesignTokens.primaryEnd],
        );
    }
  }
}

class _ChallengeVisualData {
  final String title;
  final String emoji;
  final Color color;
  final List<Color> gradientColors;

  _ChallengeVisualData({
    required this.title,
    required this.emoji,
    required this.color,
    required this.gradientColors,
  });
}
