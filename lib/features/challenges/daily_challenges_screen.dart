import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../providers/daily_challenges_provider.dart';
import '../../services/supabase_functions_service.dart';

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _supabaseService.generateDailyChallenges();

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
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D).withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          const Text(
            'Daily Challenges',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
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
              Icons.error_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load challenges',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadChallenges,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primarySolid,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          const Text(
            "Today's Challenges",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
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
        ],
      ),
    );
  }

  Widget _buildProgressOverviewCard(int completedCount) {
    final totalChallenges = _challenges.length;
    final progress = totalChallenges > 0 ? completedCount / totalChallenges : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.3),
                const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.5),
              width: 2,
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
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount / $totalChallenges',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: completedCount == totalChallenges
                            ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (completedCount == totalChallenges
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF6366F1))
                              .withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        completedCount == totalChallenges ? '✓' : '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
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
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: completedCount == totalChallenges
                              ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
              if (completedCount == totalChallenges) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'All challenges completed! Great job!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF22C55E),
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
              color: const Color(0xFF0B0B0D).withValues(alpha: isCompleted ? 0.4 : 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                    : challengeData.color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                              )
                            : LinearGradient(colors: challengeData.gradientColors),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted
                                    ? const Color(0xFF22C55E)
                                    : challengeData.color)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 32)
                            : Text(
                                challengeData.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                      ),
                    ),

                    const SizedBox(width: 16),

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
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.white,
                              decoration:
                                  isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
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
                              color: Colors.white.withValues(alpha: 0.1),
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
                                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
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
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rewards
                Row(
                  children: [
                    _buildRewardChip('+$xpReward XP', const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    _buildRewardChip('+$coinReward', const Color(0xFFFFD700), isCoins: true),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCoins)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 14),
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
            color: const Color(0xFF0B0B0D).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
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
                    const Text(
                      'Pro Tip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Complete all 3 challenges daily to maximize your rewards!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
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
          color: const Color(0xFF8B5CF6),
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
      case 'earnXp':
        return _ChallengeVisualData(
          title: 'XP Hunter',
          emoji: '⚡',
          color: const Color(0xFF3B82F6),
          gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case 'earnCoins':
        return _ChallengeVisualData(
          title: 'Coin Collector',
          emoji: '💰',
          color: const Color(0xFFF59E0B),
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case 'completeLesson':
        return _ChallengeVisualData(
          title: 'Knowledge Seeker',
          emoji: '📚',
          color: const Color(0xFF10B981),
          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
        );
      case 'perfectScore':
        return _ChallengeVisualData(
          title: 'Perfectionist',
          emoji: '🎯',
          color: const Color(0xFFEF4444),
          gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
      case 'winQuiz':
        return _ChallengeVisualData(
          title: 'Quiz Champion',
          emoji: '🏆',
          color: const Color(0xFFFFD700),
          gradientColors: const [Color(0xFFFFD700), Color(0xFFFFC107)],
        );
      default:
        return _ChallengeVisualData(
          title: 'Challenge',
          emoji: '🎯',
          color: const Color(0xFF6366F1),
          gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
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
