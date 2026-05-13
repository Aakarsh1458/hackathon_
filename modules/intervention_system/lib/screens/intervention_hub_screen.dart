import 'package:flutter/material.dart';

import '../providers/intervention_provider.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/guardian_mode_panel.dart';
import '../widgets/intervention_recommendation_widget.dart';
import '../widgets/wellness_overlay.dart';

class InterventionHubScreen extends StatelessWidget {
  const InterventionHubScreen({
    super.key,
    required this.provider,
  });

  final InterventionProvider provider;

  @override
  Widget build(BuildContext context) {
    final environment = provider.environment;
    if (environment == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final crisisMode = provider.crisisMode;
        final breathing = provider.breathing;
        final guardianMode = provider.guardianMode;
        return WellnessOverlay(
          environment: environment,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    crisisMode.enabled ? 'Stabilization mode' : 'Adaptive wellness space',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: environment.theme.typographyWeight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (crisisMode.enabled)
                    _CrisisSupportPanel(actions: crisisMode.quickActions),
                  if (guardianMode != null) ...<Widget>[
                    const SizedBox(height: 12),
                    GuardianModePanel(mode: guardianMode),
                  ],
                  if (breathing != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Center(
                      child: BreathingCircle(
                        inhaleSeconds: breathing.inhaleSeconds,
                        holdSeconds: breathing.holdSeconds,
                        exhaleSeconds: breathing.exhaleSeconds,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  InterventionRecommendationWidget(
                    recommendations: <String>[
                      ...provider.recommendations,
                      ...provider.dopamineReplacements.take(2),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CrisisSupportPanel extends StatelessWidget {
  const _CrisisSupportPanel({required this.actions});

  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Focus on one calming step',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $action', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
