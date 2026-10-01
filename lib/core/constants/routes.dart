abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const settings = '/settings';

  /// Shown when an authenticated user has no usable tenant (no active
  /// membership, or their school is invalid/suspended).
  static const tenantError = '/tenant-error';
}
