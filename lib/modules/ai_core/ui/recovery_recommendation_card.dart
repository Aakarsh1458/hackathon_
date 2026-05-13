import 'package:flutter/material.dart';

import '../chat/chat_models.dart';

/// Displays a set of wellness recommendations as safe UI cards.
class RecoveryRecommendationCard extends StatelessWidget {
  const RecoveryRecommendationCard({
    super.key,
    required this.items,
  });

  final List<WellnessRecommendation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gentle suggestions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.32),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.severity >= 2
                          ? Icons.warning_rounded
                          : item.severity == 1
                              ? Icons.tips_and_updates_rounded
                              : Icons.favorite_outline_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.body,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

