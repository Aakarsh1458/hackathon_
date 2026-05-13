import 'emotion_data.dart';
import 'emotion_label.dart';

/// Timestamped journal line optionally linked to an expression snapshot.
class MoodEntry {
  MoodEntry({
    required this.id,
    required this.createdAt,
    required this.body,
    this.linkedEmotion,
    this.linkedConfidences,
  });

  final String id;
  final DateTime createdAt;
  final String body;
  final EmotionLabel? linkedEmotion;
  final Map<EmotionLabel, double>? linkedConfidences;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'body': body,
        'linkedEmotion': linkedEmotion?.name,
        'linkedConfidences': linkedConfidences?.map((k, v) => MapEntry(k.name, v)),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    EmotionLabel? le;
    final len = json['linkedEmotion'] as String?;
    if (len != null) {
      for (final e in EmotionLabel.values) {
        if (e.name == len) {
          le = e;
          break;
        }
      }
    }
    Map<EmotionLabel, double>? lc;
    final lcm = json['linkedConfidences'] as Map<String, dynamic>?;
    if (lcm != null) {
      lc = {};
      for (final e in EmotionLabel.values) {
        final v = lcm[e.name];
        if (v is num) lc[e] = v.toDouble();
      }
    }
    return MoodEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      body: json['body'] as String,
      linkedEmotion: le,
      linkedConfidences: lc,
    );
  }

  /// Optional factory when saving right after a live [EmotionData] capture.
  factory MoodEntry.fromTextWithSignal({
    required String id,
    required String body,
    EmotionData? signal,
  }) {
    return MoodEntry(
      id: id,
      createdAt: DateTime.now(),
      body: body,
      linkedEmotion: signal?.dominant,
      linkedConfidences:
          signal != null ? Map<EmotionLabel, double>.from(signal.confidences) : null,
    );
  }
}
