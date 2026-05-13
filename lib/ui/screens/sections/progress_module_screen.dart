import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/responsive.dart';
import '../../../shared/providers/demo_metrics_provider.dart';
import '../../navigation/route_paths.dart';
import '../../widgets/app_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/module_containers/intervention_container.dart';
import '../../widgets/score_ring.dart';
import '../../widgets/sparkline.dart';
import '../../widgets/wellness_preview_video.dart';

/// Recovery / momentum hub — demo metrics plus intervention module surface.
class ProgressModuleScreen extends ConsumerWidget {
  const ProgressModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final metrics = ref.watch(demoMetricsProvider);
    final layout = screenClassOf(context);
    final columns = switch (layout) {
      ScreenClass.compact => 1,
      ScreenClass.medium => 2,
      ScreenClass.expanded => 3,
    };

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recovery progress',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Synthetic demo metrics plus live intervention tooling.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ScoreRing(
                          score0to100: metrics.wellnessScore,
                          label: 'wellness',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const WellnessPreviewVideo(compact: true),
                    const SizedBox(height: 18),
                    _MetricGrid(
                      columns: columns,
                      metrics: metrics,
                      scheme: scheme,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Intervention system',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    const GlassCard(
                      child: InterventionContainer(),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go(RoutePaths.dashboard),
                        icon: const Icon(Icons.dashboard_outlined),
                        label: const Text('Back to dashboard'),
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

class _MetricGrid extends ConsumerWidget {
  const _MetricGrid({
    required this.columns,
    required this.metrics,
    required this.scheme,
  });

  final int columns;
  final DemoMetrics metrics;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      GlassCard(
        child: _Tile(
          title: 'Stress index',
          value: '${metrics.stressIndex}/100',
          icon: Icons.bolt_rounded,
          accent: scheme.tertiary,
          footer: Sparkline(points: metrics.trend),
        ),
      ),
      GlassCard(
        child: _Tile(
          title: 'Recovery progress',
          value: '${(metrics.recoveryProgress * 100).round()}%',
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
        child: _Tile(
          title: 'Daily streak',
          value: '${metrics.streakDays} days',
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
    ];

    if (columns <= 1) {
      return Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const gap = 12.0;
        final tileW = (w - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles)
              SizedBox(
                width: tileW,
                child: t,
              ),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.footer,
  });

  final String title;
  final String value;
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
          value,
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
