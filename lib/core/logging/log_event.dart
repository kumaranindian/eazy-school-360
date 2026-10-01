/// Standardized, traceable application event names.
///
/// Use these (not ad hoc strings) when logging through [AppLogger] so that
/// important events stay greppable and consistent across the codebase as
/// new modules are added.
enum AppLogEvent {
  userLogin,
  userLogout,
  tenantResolved,
  tenantAccessDenied,
  accessDenied,
  unexpectedError,
}

extension AppLogEventX on AppLogEvent {
  /// The structured, machine-greppable event code (e.g. `USER_LOGIN`).
  String get code {
    switch (this) {
      case AppLogEvent.userLogin:
        return 'USER_LOGIN';
      case AppLogEvent.userLogout:
        return 'USER_LOGOUT';
      case AppLogEvent.tenantResolved:
        return 'TENANT_RESOLVED';
      case AppLogEvent.tenantAccessDenied:
        return 'TENANT_ACCESS_DENIED';
      case AppLogEvent.accessDenied:
        return 'ACCESS_DENIED';
      case AppLogEvent.unexpectedError:
        return 'UNEXPECTED_ERROR';
    }
  }
}
