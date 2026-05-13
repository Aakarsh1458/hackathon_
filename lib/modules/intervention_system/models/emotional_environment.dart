import 'package:flutter/foundation.dart';

import 'adaptive_theme.dart';

@immutable
class EmotionalEnvironment {
  const EmotionalEnvironment({
    required this.theme,
    required this.motionPacingSeconds,
    required this.overlayOpacity,
    required this.lowStimulationMode,
    required this.ambientGlow,
  });

  final AdaptiveTheme theme;
  final double motionPacingSeconds;
  final double overlayOpacity;
  final bool lowStimulationMode;
  final double ambientGlow;
}
