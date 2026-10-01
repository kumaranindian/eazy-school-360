import '../context/tenant_context.dart';
import '../errors/failures.dart';
import '../logging/app_logger.dart';
import '../logging/log_event.dart';
import '../models/permission.dart';

/// The single place feature modules should ask "is this allowed?".
///
/// This complements, and never replaces, `firestore.rules` — this check
/// protects the UI/UX (e.g. hiding a "Manage School" action, failing fast
/// with a clear message); the rules are what actually stop a malicious
/// client. See CLAUDE.md "Security must be enforced server-side/security-rule-side".
abstract final class AuthorizationService {
  static bool hasPermission(TenantContext context, Permission permission) {
    return context.has(permission);
  }

  /// Throws [AccessDeniedFailure] if [context] lacks [permission].
  static void requirePermission(TenantContext context, Permission permission) {
    if (context.has(permission)) return;
    AppLogger.event(AppLogEvent.accessDenied, data: {
      'uid': context.user.id,
      'permission': permission.name,
    });
    throw const AccessDeniedFailure();
  }

  /// Throws [AccessDeniedFailure] if [context] is school-scoped and its
  /// school does not match [schoolId]. A platform admin always passes.
  static void requireSameSchool(TenantContext context, String schoolId) {
    if (context.isPlatformAdmin) return;
    if (context.schoolId == schoolId) return;
    AppLogger.event(AppLogEvent.tenantAccessDenied, data: {
      'uid': context.user.id,
      'requestedSchoolId': schoolId,
      'ownSchoolId': context.schoolId,
    });
    throw const AccessDeniedFailure();
  }
}
