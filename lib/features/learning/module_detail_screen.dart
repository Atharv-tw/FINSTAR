import 'package:finstar_app/features/learning/widgets/road_lesson_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/learning_module.dart';
import '../../data/learning_modules_data.dart';
import 'learning_theme.dart';
import '../../shared/widgets/dynamic_nature_background.dart';

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
  late ScrollController _scrollController;
  final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);
  double? _roadWidgetHeight; // State variable to hold the height from RoadLessonWidget

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    try {
      module = LearningModulesData.getModuleById(widget.moduleId);
    } catch (e) {
      errorMessage = 'Module "${widget.moduleId}" not found';
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

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      _scrollProgress.value = progress;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (module == null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          const DynamicNatureBackground(),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildModuleIcon(),
                      const SizedBox(height: 24),
                      Text(module!.title, style: LearningTheme.headline1.copyWith(color: Colors.white), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        module!.description,
                        style: LearningTheme.bodyText2.copyWith(color: Colors.white.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildProgressCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: _roadWidgetHeight ?? (module!.lessons.length * 200.0), // Use reported height or fallback
                  child: RoadLessonWidget(
                    module: module!,
                    scrollProgress: _scrollProgress,
                    onHeightCalculated: (height) {
                      if (_roadWidgetHeight != height) { // Only update if height changed to avoid unnecessary rebuilds
                        setState(() {
                          _roadWidgetHeight = height;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          _buildFixedHeader(),
        ],
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: LearningTheme.forest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: LearningTheme.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              Text(
                errorMessage ?? 'Module not found',
                style: LearningTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: LearningTheme.olivine.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: LearningTheme.olivine, width: 2),
        boxShadow: [
          BoxShadow(
            color: LearningTheme.olivine.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: module!.iconPath.startsWith('http')
            ? Image.network(module!.iconPath, width: 60, height: 60, fit: BoxFit.contain)
            : Image.asset(module!.iconPath, width: 60, height: 60, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: LearningTheme.button.copyWith(color: Colors.white)),
              Text(
                '${module!.completedLessons} / ${module!.lessons.length} lessons',
                style: LearningTheme.button.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP Earned', style: LearningTheme.button.copyWith(color: Colors.white)),
              Text(
                '${module!.earnedXp} / ${module!.totalXp} XP',
                style: LearningTheme.button.copyWith(color: LearningTheme.olivine),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
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
                decoration: const BoxDecoration(
                  color: LearningTheme.olivine
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
