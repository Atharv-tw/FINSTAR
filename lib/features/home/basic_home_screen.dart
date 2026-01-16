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
import '../../shared/widgets/user_profile_card.dart';
import '../../shared/widgets/level_progress_bar.dart';

/// FINSTAR Home Screen - Redesigned for maximum impact
class BasicHomeScreen extends ConsumerStatefulWidget {
  const BasicHomeScreen({super.key}); // Added a comment to force re-compilation

  @override
  ConsumerState<BasicHomeScreen> createState() => _BasicHomeScreenState();
}

class _BasicHomeScreenState extends ConsumerState<BasicHomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                      displayName: userData.displayName,
                    ),

                    const SizedBox(height: 20),

                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Profile Card
                          UserProfileCard(user: userData),
                          const SizedBox(height: 20),
                          LevelProgressBar(user: userData),

                          const SizedBox(height: 31),

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
                            color: DesignTokens.textPrimary.withOpacity(0.08),
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
}
