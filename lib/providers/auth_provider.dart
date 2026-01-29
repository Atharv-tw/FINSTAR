import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service_free.dart';

/// Provider for the Firebase service
final authServiceProvider = Provider<FirebaseServiceFree>((ref) {
  return FirebaseServiceFree();
});

/// Provider for the current Firebase user
/// Returns null if not authenticated
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// Provider for the current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (error, stack) => null,
  );
});
