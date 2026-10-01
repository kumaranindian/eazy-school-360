import '../models/app_user.dart';

abstract interface class UserRepository {
  Stream<AppUser?> watchUser(String userId);

  Future<AppUser?> getUser(String userId);

  /// Creates the application user profile the first time a Firebase Auth
  /// identity signs in. Idempotent.
  Future<void> ensureUserProfile({
    required String userId,
    required String email,
    required String displayName,
  });
}
