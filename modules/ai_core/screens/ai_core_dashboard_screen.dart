import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_core_controller.dart';
import '../providers/ai_core_providers.dart';
import '../services/signal_sources.dart';
import '../widgets/insight_summary.dart';
import '../widgets/risk_indicator_card.dart';
import '../widgets/score_card.dart';
import '../widgets/trend_line_chart.dart';

/// Standalone dashboard surface for the host app to embed anywhere.
/// No routing assumptions.
class AiCoreDashboardScreen extends ConsumerWidget {
  final EmotionSignalSource emotionSource;
  final JournalSignalSource journalSource;
  final ActivitySignalSource activitySource;
  final WearableSignalSource? wearableSource;

  final DateTime from;
  final DateTime to;

  const AiCoreDashboardScreen({
    super.key,
    required this.emotionSource,
    required this.journalSource,
    required this.activitySource,
    required this.from,
    required this.to,
    this.wearableSource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(aiCoreControllerProvider);

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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Core • Insights',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Wellness indicators & recovery-focused risk estimation (not a diagnosis).',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: controller.loading
                            ? null
                            : () async {
                                await ref.read(aiCoreControllerProvider).refresh(
                                      from: from,
                                      to: to,
                                      emotionSource: emotionSource,
                                      journalSource: journalSource,
                                      activitySource: activitySource,
                                      wearableSource: wearableSource,
                                    );
                              },
                        child: controller.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _Body(controller: controller),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AiCoreController controller;
  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    final analysis = controller.latest;
    if (controller.lastError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.red.withValues(alpha: 0.10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
        ),
        child: Text(
          'Could not load analytics for this window.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.84)),
        ),
      );
    }

    if (analysis == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          'Tap Refresh to generate wellness indicators for the selected window.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          children: [
            ScoreCard(
              title: 'Wellness',
              score: analysis.wellness.emotionalWellness,
              subtitle: 'Emotional wellness indicator',
              accent: const Color(0xFF7C3AED),
            ),
            ScoreCard(
              title: 'Stress',
              score: analysis.wellness.stress,
              subtitle: 'Stress indicator',
              accent: const Color(0xFF06B6D4),
            ),
            ScoreCard(
              title: 'Burnout risk',
              score: analysis.wellness.burnoutRisk,
              subtitle: 'Burnout-risk indicator',
              accent: const Color(0xFFF59E0B),
            ),
            ScoreCard(
              title: 'Stability',
              score: analysis.wellness.emotionalStability,
              subtitle: 'Emotional stability indicator',
              accent: const Color(0xFF22C55E),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RiskIndicatorCard(
          title: 'Relapse-risk estimation',
          tier: analysis.relapseRisk.tier,
          confidence: analysis.relapseRisk.confidence,
          factors: analysis.relapseRisk.factors,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TrendLineChart(
                points: analysis.wellness.emotionalTrend,
                accent: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TrendLineChart(
                points: analysis.wellness.stressTrend,
                accent: const Color(0xFF06B6D4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InsightSummary(insights: analysis.recoveryInsights),
      ],
    );
  }
}

