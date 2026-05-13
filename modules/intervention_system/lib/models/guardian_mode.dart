import 'package:flutter/foundation.dart';

@immutable
class GuardianMode {
  const GuardianMode({
    required this.enabled,
    required this.pauseSeconds,
    required this.gentlePrompt,
    required this.dopamineReplacements,
  });

  final bool enabled;
  final int pauseSeconds;
  final String gentlePrompt;
  final List<String> dopamineReplacements;
}
