import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/routes.dart';
import '../../../core/context/tenant_context_provider.dart';
import '../../authentication/presentation/auth_controller.dart';

/// Tenant-aware application shell: school name, primary navigation, and the
/// user menu. Minimal by design (Part 21) — full school branding/settings
/// are later features.
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _destinations = [
    _ShellDestination(route: AppRoutes.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined),
    _ShellDestination(route: AppRoutes.settings, label: 'Settings', icon: Icons.settings_outlined),
  ];

  int _indexForLocation(String location) {
    final index = _destinations.indexWhere((d) => location.startsWith(d.route));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantAsync = ref.watch(tenantContextProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexForLocation(location);
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    final schoolName = tenantAsync.valueOrNull?.school?.name ??
        (tenantAsync.valueOrNull?.isPlatformAdmin == true ? 'Platform Admin' : 'EazySchool 360');

    final body = Row(
      children: [
        if (isWide)
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => context.go(_destinations[i].route),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.school, size: 32),
            ),
            destinations: _destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShellAppBar(schoolName: schoolName),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(_destinations[i].route),
              destinations: _destinations
                  .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
                  .toList(),
            ),
    );
  }
}

class _ShellAppBar extends ConsumerWidget {
  const _ShellAppBar({required this.schoolName});

  final String schoolName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantAsync = ref.watch(tenantContextProvider);
    final userEmail = tenantAsync.valueOrNull?.user.email ?? '';

    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.school_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schoolName,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Account',
              onSelected: (value) {
                if (value == 'sign-out') {
                  ref.read(authControllerProvider.notifier).signOut();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(enabled: false, child: Text(userEmail, overflow: TextOverflow.ellipsis)),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'sign-out', child: Text('Sign out')),
              ],
              child: const CircleAvatar(child: Icon(Icons.person_outline)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({required this.route, required this.label, required this.icon});

  final String route;
  final String label;
  final IconData icon;
}
