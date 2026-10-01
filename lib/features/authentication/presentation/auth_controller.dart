import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/failures.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/logging/log_event.dart';
import '../../../core/models/auth_identity.dart';

/// The current authenticated identity, kept live from Firebase Auth.
///
/// This is step one of the chain described in CLAUDE.md:
/// `AuthService -> TenantContext -> AuthorizationService -> Feature`.
/// Nothing downstream should talk to `FirebaseAuth` directly — it goes
/// through this controller.
final authStateProvider = StreamProvider<AuthIdentity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Drives the login form: holds the in-flight sign-in attempt and surfaces a
/// safe [Failure] on error. Does not hold the live auth state — that's
/// [authStateProvider], which updates independently (e.g. on token expiry).
class AuthController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final identity = await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      await ref.read(userRepositoryProvider).ensureUserProfile(
            userId: identity.uid,
            email: identity.email,
            displayName: identity.email,
          );
      AppLogger.event(AppLogEvent.userLogin, data: {'uid': identity.uid});
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      if (error is! Failure) {
        AppLogger.error('Sign-in failed unexpectedly', error, stackTrace);
      }
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    final uid = ref.read(authRepositoryProvider).currentIdentity?.uid;
    await ref.read(authRepositoryProvider).signOut();
    AppLogger.event(AppLogEvent.userLogout, data: {'uid': uid});
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
