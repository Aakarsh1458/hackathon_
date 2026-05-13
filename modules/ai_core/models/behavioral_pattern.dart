/// Non-diagnostic behavioral pattern extracted from signals.
class BehavioralPattern {
  final String id;
  final String title;
  final String description;

  /// 0..1 strength of the pattern in recent history.
  final double strength;

  /// Example: "late_night_activity", "isolation", "negative_spike_cycle"
  final List<String> tags;

  /// Optional time bucket label such as "00:00-03:00".
  final String? vulnerableWindowLabel;

  const BehavioralPattern({
    required this.id,
    required this.title,
    required this.description,
    required this.strength,
    this.tags = const [],
    this.vulnerableWindowLabel,
  });
}

