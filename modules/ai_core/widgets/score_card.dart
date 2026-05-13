import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String title;
  final double score; // 0..100
  final String subtitle;
  final Color accent;

  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final s = score.clamp(0, 100).toDouble();
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: s / 100),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: v,
                      strokeWidth: 6.5,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                    Text('${(v * 100).round()}',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.72)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

