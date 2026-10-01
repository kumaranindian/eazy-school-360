import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/context/tenant_context_provider.dart';

/// Minimal dashboard — exists only to prove the chain in Part 21 works:
/// `Login -> User -> School -> Tenant Context -> Dashboard`.
/// Real dashboard widgets/metrics are a later feature.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantAsync = ref.watch(tenantContextProvider);

    return tenantAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('$error')),
      data: (context_) {
        if (context_ == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${context_.user.displayName}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Role: ${context_.role.value}'),
              if (context_.school != null) Text('School: ${context_.school!.name}'),
              if (context_.isPlatformAdmin) const Text('Scope: all schools (platform admin)'),
            ],
          ),
        );
      },
    );
  }
}
