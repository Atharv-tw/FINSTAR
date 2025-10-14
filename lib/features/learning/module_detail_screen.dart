import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens.dart';
import '../../models/learning_module.dart';
import '../../data/learning_modules_data.dart';

/// Module Detail Screen - Shows all lessons in a module
class ModuleDetailScreen extends StatefulWidget {
  final String moduleId;

  const ModuleDetailScreen({
    super.key,
    required this.moduleId,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen>
    with SingleTickerProviderStateMixin {
  LearningModule? module;
  late AnimationController _animationController;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      module = LearningModulesData.getModuleById(widget.moduleId);
    } catch (e) {
      errorMessage = 'Module "${widget.moduleId}" not found';
      print('Error loading module: ${widget.moduleId}');
      print('Available modules: ${LearningModulesData.allModules.map((m) => m.id).join(", ")}');
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    if (module != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error screen if module not found
    if (module == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: DesignTokens.beigeGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: DesignTokens.textDarkPrimary),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            errorMessage ?? 'Module not found',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Available modules: ${LearningModulesData.allModules.map((m) => m.id).join(", ")}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Spacer for fixed header
                const SliverToBoxAdapter(
                  child: SizedBox(height: 72),
                ),

                // Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Module Icon
                        _buildModuleIcon(screenWidth),

                        const SizedBox(height: 24),

                        // Module Title
                        Text(
                          module!.title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Module Description
                        Text(
                          module!.description,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Progress Card
                        _buildProgressCard(),

                        const SizedBox(height: 32),

                        // Lessons Header
                        Text(
                          'Lessons (${module!.lessons.length})',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Lessons List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lesson = module!.lessons[index];
                        return _buildLessonCard(lesson, index);
                      },
                      childCount: module!.lessons.length,
                    ),
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),

            // Fixed top header
            _buildFixedHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
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
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back button on left
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),

              const Spacer(),

              // Centered title
              Text(
                module!.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Invisible spacer for centering
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleIcon(double screenWidth) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: module!.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: module!.gradientColors[0].withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            module!.iconPath,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0D).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
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
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '${module!.completedLessons} / ${module!.lessons.length} lessons',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 16),
              // XP Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP Earned',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '${module!.earnedXp} / ${module!.totalXp} XP',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: module!.gradientColors[0],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: module!.progress),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: module!.gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: module!.gradientColors[0].withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, int index) {
    final delay = index * 0.1;

    // Sequential unlocking logic:
    // First 3 lessons (index 0, 1, 2): Always unlocked
    // Lessons 4+ (index 3+): Locked unless previous lesson is completed
    final bool isLocked;
    if (index < 3) {
      isLocked = false; // First 3 lessons always unlocked
    } else {
      final previousLesson = module!.lessons[index - 1];
      isLocked = !previousLesson.isCompleted; // Locked if previous not completed
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final staggerValue =
            (_animationController.value - delay).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - staggerValue)),
          child: Opacity(
            opacity: staggerValue,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () {
            if (!isLocked) {
              HapticFeedback.mediumImpact();
              context.push('/lesson/${widget.moduleId}/${lesson.id}').then((_) {
                // Refresh the UI when returning from lesson screen
                setState(() {});
              });
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLocked
                      ? const Color(0xFF0B0B0D).withValues(alpha: 0.3)
                      : const Color(0xFF0B0B0D).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: lesson.isCompleted
                        ? module!.gradientColors[0].withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isLocked
                            ? null
                            : LinearGradient(
                                colors: module!.gradientColors,
                              ),
                        color: isLocked
                            ? Colors.white.withValues(alpha: 0.1)
                            : null,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.lock
                            : lesson.isCompleted
                                ? Icons.check_circle
                                : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Lesson Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isLocked
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${lesson.estimatedMinutes} min',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.stars,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${lesson.xpReward} XP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    if (!isLocked)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
