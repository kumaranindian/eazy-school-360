import '../models/app_user.dart';
import '../models/permission.dart';
import '../models/role.dart';
import '../models/school.dart';
import '../models/school_membership.dart';

/// The resolved application context for the current request/session:
///
/// ```
/// Current authenticated user -> User membership -> School/Tenant -> Role -> Permissions
/// ```
///
/// This is what every future feature module should consume instead of
/// re-deriving tenant/role information itself (see CLAUDE.md, Part 16).
/// Produced by `tenantContextProvider`, which is the only place allowed to
/// assemble one.
class TenantContext {
  const TenantContext({
    required this.user,
    required this.membership,
    required this.school,
    required this.role,
    required this.permissions,
  });

  final AppUser user;
  final SchoolMembership membership;

  /// Null for a platform admin, who is not scoped to a single school.
  final School? school;

  final AppRole role;
  final Set<Permission> permissions;

  bool get isPlatformAdmin => role == AppRole.platformAdmin;

  bool has(Permission permission) => permissions.contains(permission);

  /// The id to scope tenant-owned queries by. Null only for a platform
  /// admin acting at the platform level.
  String? get schoolId => school?.id ?? membership.schoolId;
}
