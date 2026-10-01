import '../constants/routes.dart';

/// Pure, framework-free redirect decision — kept separate from `go_router`
/// wiring so tenant-isolation routing rules can be unit tested directly
/// (see `test/core/routing/route_guard_test.dart`) without standing up a
/// widget tree or a real Firebase backend.
///
/// Returns the path to redirect to, or `null` to allow [currentLocation].
String? computeRedirect({
  required String currentLocation,
  required bool isAuthResolved,
  required bool isAuthenticated,
  required bool isTenantResolved,
  required bool hasTenantError,
  required bool hasTenant,
}) {
  // Still resolving auth state — don't redirect yet, let the splash/loading
  // UI show over whatever route was requested.
  if (!isAuthResolved) return null;

  if (!isAuthenticated) {
    return currentLocation == AppRoutes.login ? null : AppRoutes.login;
  }

  // Authenticated from here on. Never allow staying on the public login
  // route once signed in.
  final cameFromLogin = currentLocation == AppRoutes.login;

  if (!isTenantResolved) {
    return cameFromLogin ? null : null;
  }

  if (hasTenantError) {
    return currentLocation == AppRoutes.tenantError ? null : AppRoutes.tenantError;
  }

  if (!hasTenant) {
    // Tenant resolved with no error and no tenant shouldn't happen in
    // practice (hasTenantError covers the "no membership" case), but fail
    // closed rather than allowing access.
    return currentLocation == AppRoutes.tenantError ? null : AppRoutes.tenantError;
  }

  if (cameFromLogin || currentLocation == '/') {
    return AppRoutes.dashboard;
  }

  return null;
}
