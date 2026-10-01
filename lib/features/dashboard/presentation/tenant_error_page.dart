import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/context/tenant_context_provider.dart';
import '../../../core/errors/failures.dart';
import '../../authentication/presentation/auth_controller.dart';

/// Shown when an authenticated user has no usable tenant — see
/// `computeRedirect` in `core/routing/route_guard.dart`. Deliberately plain:
/// this is an error state, not a feature surface.
class TenantErrorPage extends ConsumerWidget {
  const TenantErrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantAsync = ref.watch(tenantContextProvider);
    final failure = tenantAsync.hasError ? tenantAsync.error : null;

    final message = switch (failure) {
      TenantNotFoundFailure(message: final m) => m,
      InvalidTenantFailure(message: final m) => m,
      Failure(message: final m) => m,
      _ => 'This account is not associated with an active school.',
    };

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
