/// Standardized, user-safe failure types.
///
/// Every repository/service boundary in the app must translate raw
/// exceptions (Firebase errors, network errors, etc.) into one of these
/// before they reach the UI. [message] must never contain sensitive
/// internal detail (stack traces, raw backend error strings, tokens) —
/// that detail belongs in [AppLogger], not in what the user sees.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The user is not signed in but the action requires authentication.
final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message = 'You need to sign in to continue.']);
}

/// The user is signed in but is not allowed to perform this action.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'You are not authorized to perform this action.']);
}

/// The authenticated user has no resolvable school/tenant membership.
final class TenantNotFoundFailure extends Failure {
  const TenantNotFoundFailure([super.message = 'No school is associated with this account.']);
}

/// A tenant/school id was supplied or resolved but is not valid or not active.
final class InvalidTenantFailure extends Failure {
  const InvalidTenantFailure([super.message = 'This school is not available.']);
}

/// The caller attempted to access a resource outside of their tenant, or a
/// resource their role does not grant access to.
final class AccessDeniedFailure extends Failure {
  const AccessDeniedFailure([super.message = 'Access denied.']);
}

/// The requested resource does not exist.
final class ResourceNotFoundFailure extends Failure {
  const ResourceNotFoundFailure([super.message = 'The requested resource was not found.']);
}

/// Input failed validation before being sent to a backend.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Anything else — network errors, unexpected backend errors, etc.
/// The original error must be logged (see AppLogger) but never surfaced here.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong. Please try again.']);
}
