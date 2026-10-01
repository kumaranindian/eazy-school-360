import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/presentation/auth_controller.dart';
import '../di/repository_providers.dart';
import '../errors/failures.dart';
import '../logging/app_logger.dart';
import '../logging/log_event.dart';
import '../models/app_user.dart';
import '../models/permission.dart';
import '../models/school.dart';
import '../models/school_membership.dart';
import 'tenant_context.dart';

final _currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

final _appUserStreamProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(uid);
});

final _activeMembershipStreamProvider = StreamProvider<SchoolMembership?>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(membershipRepositoryProvider).watchActiveMembership(uid);
});

final _currentSchoolStreamProvider = StreamProvider<School?>((ref) {
  final schoolId = ref.watch(_activeMembershipStreamProvider).valueOrNull?.schoolId;
  if (schoolId == null) return Stream.value(null);
  return ref.watch(schoolRepositoryProvider).watchSchool(schoolId);
});

/// The single reusable application context described in CLAUDE.md:
/// `AuthService -> TenantContext -> AuthorizationService -> Feature`.
///
/// - `AsyncLoading` while any dependency is still resolving.
/// - `AsyncData(null)` when the user is simply signed out.
/// - `AsyncData(context)` once user, membership, role, and (if school-scoped)
///   school are all resolved.
/// - `AsyncError(TenantNotFoundFailure)` when signed in but has no active
///   membership.
/// - `AsyncError(InvalidTenantFailure)` when the membership's school does
///   not exist or is suspended.
final tenantContextProvider = Provider<AsyncValue<TenantContext?>>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.isLoading) return const AsyncLoading();
  if (authState.hasError) {
    return AsyncError(authState.error!, authState.stackTrace!);
  }

  final identity = authState.valueOrNull;
  if (identity == null) return const AsyncData(null);

  final userAsync = ref.watch(_appUserStreamProvider);
  final membershipAsync = ref.watch(_activeMembershipStreamProvider);

  for (final async in [userAsync, membershipAsync]) {
    if (async.isLoading) return const AsyncLoading();
    if (async.hasError) return AsyncError(async.error!, async.stackTrace!);
  }

  final user = userAsync.valueOrNull;
  final membership = membershipAsync.valueOrNull;
  if (user == null || membership == null || !membership.isActive) {
    AppLogger.event(AppLogEvent.tenantAccessDenied, data: {'uid': identity.uid});
    return AsyncError(const TenantNotFoundFailure(), StackTrace.current);
  }

  if (!membership.role.isSchoolScoped) {
    // Platform admin — not scoped to a single school.
    AppLogger.event(AppLogEvent.tenantResolved, data: {
      'uid': user.id,
      'role': membership.role.value,
    });
    return AsyncData(TenantContext(
      user: user,
      membership: membership,
      school: null,
      role: membership.role,
      permissions: rolePermissions[membership.role]!,
    ));
  }

  final schoolAsync = ref.watch(_currentSchoolStreamProvider);
  if (schoolAsync.isLoading) return const AsyncLoading();
  if (schoolAsync.hasError) {
    return AsyncError(schoolAsync.error!, schoolAsync.stackTrace!);
  }

  final school = schoolAsync.valueOrNull;
  if (school == null || !school.isActive) {
    return AsyncError(const InvalidTenantFailure(), StackTrace.current);
  }

  AppLogger.event(AppLogEvent.tenantResolved, data: {
    'uid': user.id,
    'role': membership.role.value,
    'schoolId': school.id,
  });

  return AsyncData(TenantContext(
    user: user,
    membership: membership,
    school: school,
    role: membership.role,
    permissions: rolePermissions[membership.role]!,
  ));
});
