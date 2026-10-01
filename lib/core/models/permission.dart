import 'role.dart';

/// The permission foundation for Feature 01.
///
/// Deliberately small — this is not meant to be a full fine-grained
/// permission system yet. New permissions should only be added when a
/// feature actually needs them.
enum Permission {
  /// Create/suspend schools, manage platform-level configuration.
  managePlatform,

  /// Manage settings/configuration within one's own school.
  manageOwnSchool,

  /// View one's own school's dashboard/data.
  viewOwnSchool,
}

/// Static role → permission mapping.
///
/// This is intentionally code-level (not a Firestore collection) for Phase 1
/// — see `docs/architecture/authorization.md` for why, and what would change
/// if/when permissions need to be editable at runtime.
const Map<AppRole, Set<Permission>> rolePermissions = {
  AppRole.platformAdmin: {
    Permission.managePlatform,
    Permission.manageOwnSchool,
    Permission.viewOwnSchool,
  },
  AppRole.schoolAdmin: {
    Permission.manageOwnSchool,
    Permission.viewOwnSchool,
  },
};
