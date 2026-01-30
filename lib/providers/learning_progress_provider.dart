import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:flutter/foundation.dart';

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
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
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
      .collection('learningProgress')
      .snapshots()
      .map((snapshot) {
    final progressMap = <String, LessonProgress>{};
    for (var doc in snapshot.docs) {
      final progress = LessonProgress.fromFirestore(doc.data());
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
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Mark lesson as complete
    final lessonDocRef = firestore
        .collection('users')
        .doc(userId)
        .collection('learningProgress')
        .doc('${moduleId}_$lessonId');

    batch.set(lessonDocRef, {
      'moduleId': moduleId,
      'lessonId': lessonId,
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
      'xpEarned': xpReward,
    });

    // Award XP to user
    final userDocRef = firestore.collection('users').doc(userId);
    batch.update(userDocRef, {
      'xp': FieldValue.increment(xpReward),
      'lastActiveDate': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('Lesson completed: $moduleId/$lessonId - +$xpReward XP');
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

      // TODO: Get total lessons from module data
      // For now, assume 5 lessons per module
      const totalLessons = 5;
      return completedCount / totalLessons;
    },
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});