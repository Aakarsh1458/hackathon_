import 'package:flutter/material.dart';

import 'emotional_context.dart';

@immutable
class AdaptiveTheme {
  const AdaptiveTheme({
    required this.primary,
    required this.secondary,
    required this.backgroundGradient,
    required this.typographyWeight,
    required this.visualDensity,
    required this.animationScale,
    required this.interactionSoftness,
  });

  final Color primary;
  final Color secondary;
  final List<Color> backgroundGradient;
  final FontWeight typographyWeight;
  final double visualDensity;
  final double animationScale;
  final double interactionSoftness;

  factory AdaptiveTheme.fromContext(EmotionalContext context) {
    final calmBias = (context.stressLevel + context.emotionalOverload) / 2;
    final stableBias = context.emotionalStability.clamp(0, 1);

    final isCalmMode = calmBias > 0.55 || context.fatigue > 0.6;
    return AdaptiveTheme(
      primary: isCalmMode ? const Color(0xFF6DA7A7) : const Color(0xFF7F6DFF),
      secondary: isCalmMode ? const Color(0xFFA3D5D3) : const Color(0xFFFF8AAE),
      backgroundGradient: isCalmMode
          ? const [Color(0xFF0F1D2B), Color(0xFF1C3442)]
          : const [Color(0xFF17172E), Color(0xFF32295B)],
      typographyWeight: context.fatigue > 0.7 ? FontWeight.w500 : FontWeight.w600,
      visualDensity: lerpDouble(0.65, 1.0, stableBias) ?? 0.85,
      animationScale: lerpDouble(0.55, 1.1, 1 - calmBias) ?? 0.85,
      interactionSoftness: lerpDouble(1.0, 0.5, stableBias) ?? 0.75,
    );
  }
}
