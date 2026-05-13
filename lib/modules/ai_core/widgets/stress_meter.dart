import 'package:flutter/material.dart';

class StressMeter extends StatelessWidget {
  /// 0..100 (higher = more stress indicator)
  final double stress;
  final String label;

  const StressMeter({
    super.key,
    required this.stress,
    this.label = 'Stress meter',
  });

  @override
  Widget build(BuildContext context) {
    final v = stress.clamp(0, 100).toDouble();
    final t = v / 100;
    final color = Color.lerp(const Color(0xFF4ADE80), const Color(0xFFF87171), t)!;

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
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: t,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${v.round()}/100',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
          ),
        ],
      ),
    );
  }
}

