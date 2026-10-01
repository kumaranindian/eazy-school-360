import 'package:firebase_auth/firebase_auth.dart';

import 'failures.dart';

/// Maps raw Firebase exceptions to a safe, standardized [Failure].
///
/// This is the single place that understands Firebase error codes so that
/// repositories never leak raw `FirebaseException`/`FirebaseAuthException`
/// detail to the UI layer.
Failure mapExceptionToFailure(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return const UnauthenticatedFailure('Incorrect email or password.');
      case 'user-disabled':
        return const UnauthorizedFailure('This account has been disabled.');
      case 'too-many-requests':
        return const UnexpectedFailure('Too many attempts. Please try again later.');
      default:
        return const UnexpectedFailure();
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return const AccessDeniedFailure();
      case 'not-found':
        return const ResourceNotFoundFailure();
      case 'unauthenticated':
        return const UnauthenticatedFailure();
      default:
        return const UnexpectedFailure();
    }
  }

  if (error is Failure) return error;

  return const UnexpectedFailure();
}
