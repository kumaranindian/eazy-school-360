import '../../../core/models/auth_identity.dart';

abstract interface class AuthRepository {
  /// Emits the current [AuthIdentity], or `null` when signed out. Emits
  /// immediately on subscription with the current state.
  Stream<AuthIdentity?> authStateChanges();

  AuthIdentity? get currentIdentity;

  Future<AuthIdentity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
