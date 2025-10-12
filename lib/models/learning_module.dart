import 'package:flutter/material.dart';

/// Learning Module Model
class LearningModule {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final List<Color> gradientColors;
  final List<Lesson> lessons;
  final int totalXp;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.gradientColors,
    required this.lessons,
    required this.totalXp,
  });

  int get completedLessons =>
      lessons.where((lesson) => lesson.isCompleted).length;

  double get progress => lessons.isEmpty ? 0.0 : completedLessons / lessons.length;

  int get earnedXp =>
      lessons.where((lesson) => lesson.isCompleted).fold(0, (sum, lesson) => sum + lesson.xpReward);
}

/// Lesson Model
class Lesson {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int estimatedMinutes;
  final List<LessonContent> content;
  bool isCompleted;
  bool isLocked;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.estimatedMinutes,
    required this.content,
    this.isCompleted = false,
    this.isLocked = false,
  });
}

/// Lesson Content Types
enum ContentType {
  text,
  image,
  quiz,
  tip,
  example,
}

/// Lesson Content Model
class LessonContent {
  final ContentType type;
  final String data;
  final Map<String, dynamic>? metadata;

  LessonContent({
    required this.type,
    required this.data,
    this.metadata,
  });
}

/// Quiz Question Model (for quiz content type)
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
