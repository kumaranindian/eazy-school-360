import 'package:eazy_school_360/core/constants/routes.dart';
import 'package:eazy_school_360/core/routing/route_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeRedirect — authentication', () {
    test('unauthenticated user hitting a protected route is sent to /login', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.dashboard,
        isAuthResolved: true,
        isAuthenticated: false,
        isTenantResolved: true,
        hasTenantError: false,
        hasTenant: false,
      );
      expect(redirect, AppRoutes.login);
    });

    test('unauthenticated user already on /login is not redirected', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.login,
        isAuthResolved: true,
        isAuthenticated: false,
        isTenantResolved: true,
        hasTenantError: false,
        hasTenant: false,
      );
      expect(redirect, isNull);
    });

    test('while auth state is still resolving, no redirect happens yet', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.dashboard,
        isAuthResolved: false,
        isAuthenticated: false,
        isTenantResolved: false,
        hasTenantError: false,
        hasTenant: false,
      );
      expect(redirect, isNull);
    });
  });

  group('computeRedirect — tenant resolution', () {
    test('authenticated user with a resolved tenant leaving /login goes to /dashboard', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.login,
        isAuthResolved: true,
        isAuthenticated: true,
        isTenantResolved: true,
        hasTenantError: false,
        hasTenant: true,
      );
      expect(redirect, AppRoutes.dashboard);
    });

    test('authenticated user already on a protected route with a tenant is allowed', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.settings,
        isAuthResolved: true,
        isAuthenticated: true,
        isTenantResolved: true,
        hasTenantError: false,
        hasTenant: true,
      );
      expect(redirect, isNull);
    });

    test('authenticated user with no resolvable tenant is sent to /tenant-error', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.dashboard,
        isAuthResolved: true,
        isAuthenticated: true,
        isTenantResolved: true,
        hasTenantError: true,
        hasTenant: false,
      );
      expect(redirect, AppRoutes.tenantError);
    });

    test('authenticated user on /tenant-error with a tenant error is not redirected again', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.tenantError,
        isAuthResolved: true,
        isAuthenticated: true,
        isTenantResolved: true,
        hasTenantError: true,
        hasTenant: false,
      );
      expect(redirect, isNull);
    });

    test('authenticated user whose tenant is still resolving stays put', () {
      final redirect = computeRedirect(
        currentLocation: AppRoutes.login,
        isAuthResolved: true,
        isAuthenticated: true,
        isTenantResolved: false,
        hasTenantError: false,
        hasTenant: false,
      );
      expect(redirect, isNull);
    });
  });
}
