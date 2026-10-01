import 'package:eazy_school_360/core/authorization/authorization_service.dart';
import 'package:eazy_school_360/core/context/tenant_context.dart';
import 'package:eazy_school_360/core/errors/failures.dart';
import 'package:eazy_school_360/core/models/app_user.dart';
import 'package:eazy_school_360/core/models/permission.dart';
import 'package:eazy_school_360/core/models/role.dart';
import 'package:eazy_school_360/core/models/school.dart';
import 'package:eazy_school_360/core/models/school_membership.dart';
import 'package:flutter_test/flutter_test.dart';

TenantContext _context({required AppRole role, String? schoolId}) {
  final now = DateTime(2026, 1, 1);
  return TenantContext(
    user: AppUser(
      id: 'u1',
      email: 'u1@example.com',
      displayName: 'U1',
      status: AppUserStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    membership: SchoolMembership(
      id: 'm1',
      userId: 'u1',
      schoolId: schoolId,
      role: role,
      status: MembershipStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
    school: schoolId == null
        ? null
        : School(
            id: schoolId,
            name: 'School $schoolId',
            code: 'C$schoolId',
            status: SchoolStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
    role: role,
    permissions: rolePermissions[role]!,
  );
}

void main() {
  group('AuthorizationService.requirePermission', () {
    test('passes when the role has the permission', () {
      final context = _context(role: AppRole.schoolAdmin, schoolId: 'school-a');
      expect(
        () => AuthorizationService.requirePermission(context, Permission.manageOwnSchool),
        returnsNormally,
      );
    });

    test('throws AccessDeniedFailure when the role lacks the permission', () {
      final context = _context(role: AppRole.schoolAdmin, schoolId: 'school-a');
      expect(
        () => AuthorizationService.requirePermission(context, Permission.managePlatform),
        throwsA(isA<AccessDeniedFailure>()),
      );
    });

    test('a platform admin has every permission', () {
      final context = _context(role: AppRole.platformAdmin);
      for (final permission in Permission.values) {
        expect(AuthorizationService.hasPermission(context, permission), isTrue);
      }
    });
  });

  group('AuthorizationService.requireSameSchool', () {
    test('a school admin accessing their own school passes', () {
      final context = _context(role: AppRole.schoolAdmin, schoolId: 'school-a');
      expect(
        () => AuthorizationService.requireSameSchool(context, 'school-a'),
        returnsNormally,
      );
    });

    test('a school admin accessing another school is denied', () {
      final context = _context(role: AppRole.schoolAdmin, schoolId: 'school-a');
      expect(
        () => AuthorizationService.requireSameSchool(context, 'school-b'),
        throwsA(isA<AccessDeniedFailure>()),
      );
    });

    test('a platform admin may access any school', () {
      final context = _context(role: AppRole.platformAdmin);
      expect(
        () => AuthorizationService.requireSameSchool(context, 'school-b'),
        returnsNormally,
      );
    });
  });
}
