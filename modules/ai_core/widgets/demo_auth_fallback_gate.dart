import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/demo_session_providers.dart';

/// Drop-in gate to keep the app demoable during auth integration.
///
/// Intended usage (in host app auth shell):
/// - pass `authenticatedChild` (normal path)
/// - pass `demoChild` (dashboard demo environment)
/// - if auth fails, set `authFailed=true` and provide a user-friendly message
///
/// TODO(host app): Wire `authFailed` from Firebase sign-in error state.
/// TODO(host app): Prefer showing demo option only in debug / staging.
class DemoAuthFallbackGate extends ConsumerWidget {
  final bool loading;
  final bool authenticated;
  final bool authFailed;
  final String? errorMessage;

  final Widget authenticatedChild;
  final Widget demoChild;

  const DemoAuthFallbackGate({
    super.key,
    required this.loading,
    required this.authenticated,
    required this.authFailed,
    required this.authenticatedChild,
    required this.demoChild,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loading) {
      return const _CenteredStatus(
        title: 'Signing you in…',
        subtitle: 'Preparing your wellness dashboard.',
        showSpinner: true,
      );
    }

    if (authenticated) {
      return authenticatedChild;
    }

    final demoUser = ref.watch(demoUserProvider);
    if (demoUser != null) {
      return demoChild;
    }

    if (!authFailed) {
      // Auth not complete yet, but not an explicit failure: keep the shell in control.
      return const _CenteredStatus(
        title: 'Sign-in required',
        subtitle: 'Waiting for authentication…',
        showSpinner: false,
      );
    }

    return _DemoFallbackScreen(
      errorMessage: errorMessage,
      onContinueDemo: () {
        final svc = ref.read(demoSessionServiceProvider);
        final user = svc.startDemoSession();
        ref.read(demoUserProvider.notifier).state = user;
      },
    );
  }
}

class _DemoFallbackScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onContinueDemo;

  const _DemoFallbackScreen({
    required this.errorMessage,
    required this.onContinueDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF111A2F), Color(0xFF070A12)],
              center: Alignment.topLeft,
              radius: 1.3,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.60),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo access enabled',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Authentication is still being integrated. You can continue in a safe demo session to explore the wellness dashboard.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                    if ((errorMessage ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Text(
                          errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.70),
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: onContinueDemo,
                            child: const Text('Continue in demo mode'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Note: Demo mode uses a local temporary session only. It does not bypass or modify Firebase authentication.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.60),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showSpinner;

  const _CenteredStatus({
    required this.title,
    required this.subtitle,
    required this.showSpinner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner) ...[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

