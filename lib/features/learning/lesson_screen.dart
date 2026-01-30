import 'dart:ui';
import 'package:finstar_app/features/learning/widgets/quiz_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/learning_module.dart';
import '../../data/learning_modules_data.dart';
import 'learning_theme.dart';
import '../../shared/widgets/nature_background.dart';

/// Lesson Screen - Displays lesson content
class LessonScreen extends StatefulWidget {
  final String moduleId;
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late LearningModule module;
  late Lesson lesson;
  int currentContentIndex = 0;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    module = LearningModulesData.getModuleById(widget.moduleId);
    lesson = module.lessons.firstWhere((l) => l.id == widget.lessonId);
  }

  void _nextContent() {
    if (currentContentIndex < lesson.content.length - 1) {
      setState(() {
        currentContentIndex++;
      });
    } else {
      _completeLesson();
    }
  }

  void _previousContent() {
    if (currentContentIndex > 0) {
      setState(() {
        currentContentIndex--;
      });
    }
  }

  void _completeLesson() {
    setState(() {
      lesson.isCompleted = true;
      isCompleted = true;
    });

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = lesson.content[currentContentIndex];

    return Scaffold(
      body: Stack(
        children: [
          const NatureBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Progress Indicator
                _buildProgressIndicator(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(content),
                  ),
                ),

                // Navigation Buttons
                if (content.type != ContentType.quiz) _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: LearningTheme.vanDyke),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              lesson.title,
              style: LearningTheme.headline2.copyWith(fontSize: 18, color: LearningTheme.vanDyke),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LearningTheme.olivine.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: LearningTheme.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${lesson.xpReward} XP',
                  style: LearningTheme.button.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (currentContentIndex + 1) / lesson.content.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: LearningTheme.vanDyke.withOpacity(0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: const BoxDecoration(
                color: LearningTheme.olivine,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LessonContent content) {
    switch (content.type) {
      case ContentType.text:
        return _buildTextContent(content.data ?? '');
      case ContentType.tip:
        return _buildTipContent(content.data ?? '');
      case ContentType.example:
        return _buildExampleContent(content.data ?? '');
      case ContentType.image:
        return _buildImageContent(content.data ?? '');
      case ContentType.quiz:
        return _buildQuizContent(content);
    }
  }
  
  Widget _buildGlassCard({required Widget child, Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: LearningTheme.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor ?? LearningTheme.vanDyke.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextContent(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (line.endsWith('?')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(line, style: LearningTheme.headline2.copyWith(color: LearningTheme.vanDyke)),
        ));
      } else if (RegExp(r'^[🎯💰📊✨💡🚀⚡🌟🎓💪🏦📱💵🔥🛡️⚠️📋💊🆚💝🌪️🗺️🏖️]').hasMatch(line)) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(line, style: LearningTheme.headline2.copyWith(fontSize: 22, color: LearningTheme.vanDyke)),
        ));
      } else if (line.startsWith('•') || line.startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: LearningTheme.bodyText1.copyWith(color: LearningTheme.olivine, fontWeight: FontWeight.w700)),
                Expanded(child: Text(line.replaceFirst(RegExp(r'^[•\-]\s*'), ''), style: LearningTheme.bodyText1.copyWith(color: LearningTheme.vanDyke))),
              ],
            ),
          ),
        );
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(line, style: LearningTheme.bodyText1.copyWith(color: LearningTheme.vanDyke)),
        ));
      }
    }

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildTipContent(String text) {
    return _buildGlassCard(
      borderColor: LearningTheme.olivine.withOpacity(0.7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: LearningTheme.olivine, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pro Tip', style: LearningTheme.headline2.copyWith(fontSize: 18, color: LearningTheme.olivine)),
                const SizedBox(height: 12),
                Text(text, style: LearningTheme.bodyText1.copyWith(color: LearningTheme.vanDyke)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleContent(String text) {
    return _buildGlassCard(
      borderColor: LearningTheme.columbia.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded, color: LearningTheme.columbia, size: 26),
              const SizedBox(width: 12),
              Text('Example', style: LearningTheme.headline2.copyWith(fontSize: 18, color: LearningTheme.vanDyke)),
            ],
          ),
          const SizedBox(height: 16),
          Text(text, style: LearningTheme.bodyText1.copyWith(color: LearningTheme.vanDyke)),
        ],
      ),
    );
  }

  Widget _buildImageContent(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }

  Widget _buildQuizContent(LessonContent content) {
    return _buildGlassCard(
      child: QuizWidget(
        questions: content.quizQuestions ?? [],
        onQuizCompleted: (correctAnswers) {
          // You can use the correctAnswers to update the score
          _completeLesson();
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastContent = currentContentIndex == lesson.content.length - 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (currentContentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousContent,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: LearningTheme.vanDyke.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Previous', style: LearningTheme.button.copyWith(color: LearningTheme.vanDyke)),
              ),
            ),
          if (currentContentIndex > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentContentIndex > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _nextContent,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: LearningTheme.olivine,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    isLastContent ? 'Complete Lesson' : 'Continue',
                    style: LearningTheme.button.copyWith(color: LearningTheme.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _buildGlassCard(
        borderColor: LearningTheme.olivine.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: LearningTheme.olivine,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: LearningTheme.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Lesson Complete!', style: LearningTheme.headline2.copyWith(color: LearningTheme.vanDyke)),
            const SizedBox(height: 12),
            Text('You earned ${lesson.xpReward} XP!', style: LearningTheme.bodyText2.copyWith(color: LearningTheme.vanDyke)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.pop(); // Return to module screen
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: LearningTheme.olivine,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Continue', style: LearningTheme.button.copyWith(color: LearningTheme.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
