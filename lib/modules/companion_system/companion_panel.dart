import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state_provider.dart';

class CompanionPanel extends ConsumerWidget {
  const CompanionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appStateProvider);
    final scheme = Theme.of(context).colorScheme;

    final stress = app.stressScore;
    final (title, body, icon, accent) = _messageFor(stress, app.emotionalState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Companion',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: scheme.surfaceContainerHighest.withOpacity(0.28),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.18),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'State: ${app.companionState} • Stress ${(stress * 100).round()}/100',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  (String, String, IconData, Color) _messageFor(double stress, EmotionalState state) {
    if (stress >= 0.78 || state == EmotionalState.overloaded) {
      return (
        'I’m here. Let’s slow down.',
        'Try 3 rounds of inhale 4 / exhale 6. If you can, change your environment for 2 minutes.',
        Icons.shield_rounded,
        const Color(0xFFF87171),
      );
    }
    if (stress >= 0.52 || state == EmotionalState.elevated) {
      return (
        'You’re doing your best.',
        'Want a small reset? Stretch shoulders/neck and take 5 slow breaths.',
        Icons.favorite_rounded,
        const Color(0xFFFBBF24),
      );
    }
    return (
      'Steady energy.',
      'Nice. If you’d like, set one tiny intention for the next hour.',
      Icons.emoji_emotions_rounded,
      const Color(0xFF4ADE80),
    );
  }
}

