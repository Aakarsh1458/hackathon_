import 'package:flutter/material.dart';

class InsightSummary extends StatelessWidget {
  final List<String> insights;
  const InsightSummary({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = insights.where((e) => e.trim().isNotEmpty).take(6).toList(growable: false);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recovery insights', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No insights yet for this window.',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.72)),
            )
          else
            ...items.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t,
                          style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.82)),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

