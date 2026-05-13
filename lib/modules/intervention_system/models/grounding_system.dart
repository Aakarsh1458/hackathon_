import 'package:flutter/foundation.dart';

@immutable
class GroundingSystem {
  const GroundingSystem({
    required this.breathingCycles,
    required this.focusTimerSeconds,
    required this.mindfulCardPrompts,
  });

  final int breathingCycles;
  final int focusTimerSeconds;
  final List<String> mindfulCardPrompts;
}
