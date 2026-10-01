import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/auth_controller.dart';
import '../../features/authentication/presentation/login_page.dart';
import '../../features/dashboard/presentation/app_shell.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dashboard/presentation/settings_page.dart';
import '../../features/dashboard/presentation/tenant_error_page.dart';
import '../constants/routes.dart';
import '../context/tenant_context_provider.dart';
import 'route_guard.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(tenantContextProvider, (_, __) => notifyListeners());
  }
}

/// Tenant-aware routing (Part 22): protected routes are only reachable once
/// authentication AND tenant resolution succeed — enforced here via
/// `redirect`, not by merely hiding navigation items.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final tenantState = ref.read(tenantContextProvider);

      return computeRedirect(
        currentLocation: state.matchedLocation,
        isAuthResolved: !authState.isLoading,
        isAuthenticated: authState.valueOrNull != null,
        isTenantResolved: !tenantState.isLoading,
        hasTenantError: tenantState.hasError,
        hasTenant: tenantState.valueOrNull != null,
      );
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.tenantError, builder: (context, state) => const TenantErrorPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (context, state) => const DashboardPage()),
          GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsPage()),
        ],
      ),
    ],
  );
});
