/// Generic signal representation to keep the AI core decoupled from upstream systems.
///
/// Upstream (emotion engine, journaling, wearables) should adapt into this shape.
class EmotionalSignal {
  final DateTime timestamp;

  /// -1..1 where -1 is strongly negative, 0 neutral, +1 strongly positive.
  final double valence;

  /// 0..1 intensity/arousal.
  final double intensity;

  /// Optional emotion label (e.g., "sadness", "anxiety") if available.
  final String? label;

  const EmotionalSignal({
    required this.timestamp,
    required this.valence,
    required this.intensity,
    this.label,
  });
}

