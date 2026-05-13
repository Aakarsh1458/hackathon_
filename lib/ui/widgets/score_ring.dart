import 'package:flutter/material.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score0to100,
    this.size = 92,
    this.label,
  });

  final int score0to100;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = (score0to100.clamp(0, 100)) / 100.0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: value),
      builder: (context, v, _) {
        return SizedBox(
          height: size,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  scheme.onSurface.withOpacity(0.08),
                ),
              ),
              CircularProgressIndicator(
                value: v,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                backgroundColor: Colors.transparent,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score0to100',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (label != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      label!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

