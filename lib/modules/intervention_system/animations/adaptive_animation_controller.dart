import 'package:flutter/animation.dart';

import '../models/emotional_environment.dart';

class AdaptiveAnimationController {
  const AdaptiveAnimationController();

  Duration transitionDuration(EmotionalEnvironment environment) {
    final ms = (environment.motionPacingSeconds * 1000).round();
    return Duration(milliseconds: ms.clamp(900, 2600));
  }

  Curve transitionCurve(EmotionalEnvironment environment) {
    return environment.lowStimulationMode ? Curves.easeOutCubic : Curves.easeInOut;
  }

  double feedbackScale(EmotionalEnvironment environment) {
    return environment.theme.animationScale.clamp(0.5, 1.2);
  }
}
