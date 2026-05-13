import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_gradient_background.dart';
import '../../routes/route_paths.dart';
import '../../shared/providers/app_shell_state_provider.dart';

/// Demo-ready onboarding — persists in-memory via [AppShellState].
/// TODO: Persist to local storage when product decides on storage approach.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(appShellStateProvider.notifier).completeOnboarding();
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AppGradientBackground(
        alignBegin: Alignment.topLeft,
        alignEnd: Alignment.bottomRight,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [
                    _OnboardingPage(
                      icon: Icons.spa_outlined,
                      title: 'A calm space to reset',
                      body:
                          'This is a modular wellness shell. It stays lightweight while future systems plug in safely.',
                    ),
                    _OnboardingPage(
                      icon: Icons.insights_outlined,
                      title: 'Insights, not overload',
                      body:
                          'Dashboards are designed for low cognitive load—clear signals, gentle visuals, and accessibility-first layouts.',
                    ),
                    _OnboardingPage(
                      icon: Icons.shield_outlined,
                      title: 'Support when it matters',
                      body:
                          'Crisis and intervention surfaces exist as safe containers. Future modules will inject real content here.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    _Dots(count: 3, index: _page),
                    const Spacer(),
                    FilledButton(
                      onPressed: () async {
                        if (_page < 2) {
                          await _controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                          return;
                        }
                        _finish();
                      },
                      child: Text(_page < 2 ? 'Continue' : 'Get started'),
                    ),
                  ],
                ),
              ),
              Text(
                'Demo shell — modules integrate later.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer.withOpacity(0.55),
                  border: Border.all(
                    color: scheme.primary.withOpacity(0.35),
                  ),
                ),
                child: Icon(icon, size: 38, color: scheme.primary),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: selected ? 22 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? scheme.primary
                : scheme.onSurfaceVariant.withOpacity(0.25),
          ),
        );
      }),
    );
  }
}

