import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../data/learning_modules_data.dart';
import '../services/supabase_functions_service.dart';

/// Learning progress model
class LessonProgress {
  final String moduleId;
  final String lessonId;
  final bool completed;
  final DateTime? completedAt;
  final int xpEarned;

  LessonProgress({
    required this.moduleId,
    required this.lessonId,
    required this.completed,
    this.completedAt,
    this.xpEarned = 0,
  });

  factory LessonProgress.fromFirestore(Map<String, dynamic> data) {
    return LessonProgress(
      moduleId: data['moduleId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      completed: data['completed'] ?? false,
      completedAt: _parseDateTime(data['completedAt']),
      xpEarned: data['xpEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'moduleId': moduleId,
      'lessonId': lessonId,
      'completed': completed,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'xpEarned': xpEarned,
    };
  }
}

/// Provider for user's learning progress
final learningProgressProvider = StreamProvider<Map<String, LessonProgress>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value({});
  }

  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('lessonProgress')
      .snapshots()
      .map((snapshot) {
    debugPrint('lessonProgress docs: ${snapshot.docs.length}');
    final progressMap = <String, LessonProgress>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lessonId = (data['lessonId'] ?? doc.id) as String;
      final moduleId = _findModuleIdForLesson(lessonId) ?? (data['moduleId'] ?? '');
      debugPrint('lessonProgress doc=${doc.id} lessonId=$lessonId moduleId=$moduleId completed=${data['completed']} xpEarned=${data['xpEarned']}');
      final progress = LessonProgress(
        moduleId: moduleId,
        lessonId: lessonId,
        completed: data['completed'] ?? false,
        completedAt: _parseDateTime(data['completedAt']),
        xpEarned: data['xpEarned'] ?? 0,
      );
      progressMap['${progress.moduleId}_${progress.lessonId}'] = progress;
    }
    return progressMap;
  });
});

/// Provider for marking a lesson as complete
final completeLessonProvider = Provider((ref) {
  return ({
    required String moduleId,
    required String lessonId,
    int xpReward = 50,
  }) async {
    final result = await SupabaseFunctionsService().completeLessonWithAchievements(
      lessonId: lessonId,
    );
    if (result['success'] == true) {
      debugPrint('Lesson completed (Supabase): $moduleId/$lessonId');
    } else {
      throw Exception(result['error'] ?? 'Failed to complete lesson');
    }
  };
});

/// Provider for module completion percentage
final moduleProgressProvider = Provider.family<double, String>((ref, moduleId) {
  final progress = ref.watch(learningProgressProvider);

  return progress.when(
    data: (progressMap) {
      // Count completed lessons in this module
      final completedCount = progressMap.values
          .where((p) => p.moduleId == moduleId && p.completed)
          .length;

      int totalLessons = 0;
      try {
        totalLessons = LearningModulesData.getModuleById(moduleId).lessons.length;
      } catch (_) {
        totalLessons = 0;
      }
      return totalLessons == 0 ? 0.0 : completedCount / totalLessons;
    },
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});

String? _findModuleIdForLesson(String lessonId) {
  try {
    for (final module in LearningModulesData.allModules) {
      for (final lesson in module.lessons) {
        if (lesson.id == lessonId) {
          return module.id;
        }
      }
    }
  } catch (_) {}
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return null;
}
