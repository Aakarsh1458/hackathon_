import 'package:flutter/foundation.dart';

@immutable
class CrisisMode {
  const CrisisMode({
    required this.enabled,
    required this.minimalUi,
    required this.largeActions,
    required this.distractionReduction,
    required this.quickActions,
  });

  final bool enabled;
  final bool minimalUi;
  final bool largeActions;
  final bool distractionReduction;
  final List<String> quickActions;

  static const CrisisMode inactive = CrisisMode(
    enabled: false,
    minimalUi: false,
    largeActions: false,
    distractionReduction: false,
    quickActions: <String>[],
  );
}
