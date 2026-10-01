import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../../core/models/auth_identity.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  AuthIdentity? _toIdentity(User? user) {
    if (user == null) return null;
    return AuthIdentity(uid: user.uid, email: user.email ?? '');
  }

  @override
  Stream<AuthIdentity?> authStateChanges() =>
      _auth.authStateChanges().map(_toIdentity);

  @override
  AuthIdentity? get currentIdentity => _toIdentity(_auth.currentUser);

  @override
  Future<AuthIdentity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final identity = _toIdentity(credential.user);
      if (identity == null) {
        throw const UnauthenticatedFailure();
      }
      // Custom claims (role/schoolId) are set asynchronously by a Cloud
      // Function and only appear on a freshly-minted ID token — force a
      // refresh so tenant resolution sees them immediately after sign-in
      // instead of waiting for Firebase's ~1h natural refresh.
      await credential.user?.getIdTokenResult(true);
      return identity;
    } catch (error) {
      throw mapExceptionToFailure(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw mapExceptionToFailure(error);
    }
  }
}
