import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../providers/achievements_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

/// Profile Detail Screen - A modern, gamified view of user progress.
class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animations after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return _buildErrorState('No user data found. Please log in again.');
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildProfileContent(user),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState('Error: $error'),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(UserProfile user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 30),
            _FinstarDigitalCard(user: user),
            const SizedBox(height: 30),
            _buildStatsGrid(user),
            const SizedBox(height: 30),
            _buildAchievementsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    String levelTitle = "Level ${user.level} • Beginner Saver";
    if (user.xp > 1000) {
      levelTitle = "Level ${user.level} • Smart Investor";
    } else if (user.xp > 500) {
      levelTitle = "Level ${user.level} • Pro Spender";
    }

    double xpForNextLevel = (user.level * 1000).toDouble();
    if (xpForNextLevel == 0) xpForNextLevel = 1000;
    double currentXpProgress = user.xp / xpForNextLevel;

    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: DesignTokens.primarySolid.withOpacity(0.1),
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40, color: DesignTokens.primarySolid),
                    )
                  : null,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: DesignTokens.primarySolid, width: 2),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.edit, size: 16, color: DesignTokens.primarySolid),
            )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DesignTokens.textDarkPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                levelTitle,
                style: const TextStyle(fontSize: 14, color: DesignTokens.textDarkSecondary),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: currentXpProgress,
                  minHeight: 8,
                  backgroundColor: DesignTokens.primarySolid.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(DesignTokens.primarySolid),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${user.streakDays}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Stats",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DesignTokens.textDarkPrimary),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _StatCard(label: 'Lessons Done', value: '12', icon: Icons.library_books_rounded, color: Colors.blue),
            _StatCard(label: 'Coins Earned', value: '${user.coins}', icon: Icons.monetization_on_rounded, color: Colors.amber),
            _StatCard(label: 'Current Streak', value: '${user.streakDays} Days', icon: Icons.local_fire_department_rounded, color: Colors.deepOrange),
            _StatCard(label: 'Leaderboard', value: '#24', icon: Icons.leaderboard_rounded, color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final achievementsAsync = ref.watch(achievementsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Achievements",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DesignTokens.textDarkPrimary),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        achievementsAsync.when(
          data: (achievements) => SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _AchievementBadge(achievement: achievements[index]),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Text('Could not load achievements'),
        ),
      ],
    );
  }
}

class _FinstarDigitalCard extends StatefulWidget {
  final UserProfile user;
  const _FinstarDigitalCard({required this.user});

  @override
  State<_FinstarDigitalCard> createState() => _FinstarDigitalCardState();
}

class _FinstarDigitalCardState extends State<_FinstarDigitalCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _tiltY += details.delta.dx * 0.01;
          _tiltX -= details.delta.dy * 0.01;
        });
      },
      onPanEnd: (details) {
        setState(() {
          _tiltX = 0;
          _tiltY = 0;
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(_tiltX)
          ..rotateY(_tiltY),
        alignment: FractionalOffset.center,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primarySolid.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: -10,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Animated Gradient Background
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: SweepGradient(
                          center: Alignment.center,
                          transform: GradientRotation(_controller.value * 2 * 3.14159),
                          colors: const [
                            DesignTokens.primaryStart,
                            DesignTokens.primaryEnd,
                            DesignTokens.primaryStart,
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Glassmorphism overlay
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Card Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Finstar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const Icon(Icons.wifi, color: Colors.white),
                        ],
                      ),
                      const Spacer(),
                      const Text('COIN BALANCE', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.user.coins} Coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: DesignTokens.textDarkSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DesignTokens.textDarkPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    bool isUnlocked = achievement.unlocked;

    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: isUnlocked ? 1.0 : achievement.progressPercentage,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: isUnlocked ? achievement.color.withOpacity(0.2) : Colors.grey.shade200,
                child: Icon(
                  isUnlocked ? achievement.icon : Icons.lock_outline,
                  color: isUnlocked ? achievement.color : Colors.grey.shade400,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? DesignTokens.textDarkPrimary : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
