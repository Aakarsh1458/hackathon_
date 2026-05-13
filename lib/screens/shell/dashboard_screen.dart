import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../core/widgets/app_gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/module_containers.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/sparkline.dart';
import '../../routes/route_paths.dart';
import '../../shared/providers/demo_metrics_provider.dart';

/// Demo-ready dashboard (placeholders only) with safe module containers.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final layout = screenClassOf(context);
    final metrics = ref.watch(demoMetricsProvider);

    final columns = switch (layout) {
      ScreenClass.compact => 1,
      ScreenClass.medium => 2,
      ScreenClass.expanded => 3,
    };

    return AppGradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gentle signals + module containers. No module internals live here.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      ScoreRing(
                        score0to100: metrics.wellnessScore,
                        label: 'wellness',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Grid(
                    columns: columns,
                    gap: 12,
                    children: [
                      GlassCard(
                        child: _MetricTile(
                          title: 'Stress index',
                          valueText: '${metrics.stressIndex}/100',
                          icon: Icons.bolt_rounded,
                          accent: scheme.tertiary,
                          footer: Sparkline(points: metrics.trend),
                        ),
                      ),
                      GlassCard(
                        child: _MetricTile(
                          title: 'Recovery progress',
                          valueText: '${(metrics.recoveryProgress * 100).round()}%',
                          icon: Icons.rocket_launch_rounded,
                          accent: scheme.primary,
                          footer: LinearProgressIndicator(
                            value: metrics.recoveryProgress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      GlassCard(
                        child: _MetricTile(
                          title: 'Daily streak',
                          valueText: '${metrics.streakDays} days',
                          icon: Icons.local_fire_department_rounded,
                          accent: scheme.secondary,
                          footer: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Small steps count.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => ref.read(demoMetricsProvider.notifier).bumpStreak(),
                                child: const Text('Mark today'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Module surfaces',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _Grid(
                    columns: columns,
                    gap: 12,
                    children: const [
                      GlassCard(child: EmotionModuleContainer()),
                      GlassCard(child: AICoreContainer()),
                      GlassCard(child: InterventionModuleContainer()),
                      GlassCard(child: CompanionModuleContainer()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Quick journal entry',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () => context.go(RoutePaths.journal),
                          child: const Text('Open'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.valueText,
    required this.icon,
    required this.accent,
    required this.footer,
  });

  final String title;
  final String valueText;
  final IconData icon;
  final Color accent;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.18),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          valueText,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        footer,
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.gap,
    required this.children,
  });

  final int columns;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final tileW = (w - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(
                width: tileW,
                child: child,
              ),
          ],
        );
      },
    );
  }
}
