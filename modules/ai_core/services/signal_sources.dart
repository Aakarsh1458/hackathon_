import '../models/emotional_signal.dart';

/// Integration surface: emotion engine -> AI core.
abstract class EmotionSignalSource {
  Future<List<EmotionalSignal>> fetchSignals({
    required DateTime from,
    required DateTime to,
  });
}

/// Integration surface: journaling -> AI core.
abstract class JournalSignalSource {
  Future<List<JournalEntrySignal>> fetchJournalSignals({
    required DateTime from,
    required DateTime to,
  });
}

/// Integration surface: activity/engagement -> AI core.
abstract class ActivitySignalSource {
  Future<List<ActivitySignal>> fetchActivitySignals({
    required DateTime from,
    required DateTime to,
  });
}

/// Integration surface: future wearable -> AI core.
abstract class WearableSignalSource {
  Future<List<WearableSignal>> fetchWearableSignals({
    required DateTime from,
    required DateTime to,
  });
}

class JournalEntrySignal {
  final DateTime timestamp;

  /// 0..1, basic indicator of journaling depth (length/structure), not sentiment.
  final double depth;

  /// 0..1, how consistent the journaling cadence is.
  final double consistency;

  /// Optional tags like "craving", "stress", "sleep".
  final List<String> tags;

  const JournalEntrySignal({
    required this.timestamp,
    required this.depth,
    required this.consistency,
    this.tags = const [],
  });
}

class ActivitySignal {
  final DateTime timestamp;

  /// Active minutes or engagement units (normalized upstream if needed).
  final double activityLevel;

  /// True if this activity occurred in a late-night vulnerable window.
  final bool isLateNight;

  /// 0..1 proxy indicator for social connection (messages/calls/groups), not content.
  final double socialConnection;

  const ActivitySignal({
    required this.timestamp,
    required this.activityLevel,
    required this.isLateNight,
    required this.socialConnection,
  });
}

class WearableSignal {
  final DateTime timestamp;

  /// 0..1 normalized stress proxy (e.g., HRV-based) if available.
  final double stressProxy;

  /// 0..1 normalized sleep quality.
  final double sleepQuality;

  const WearableSignal({
    required this.timestamp,
    required this.stressProxy,
    required this.sleepQuality,
  });
}

