import 'emotion_label.dart';

/// A single frame or aggregated facial expression estimation with confidence.
class EmotionData {
  const EmotionData({
    required this.dominant,
    required this.confidences,
    required this.capturedAt,
    this.rawSmileProbability,
    this.rawLeftEyeOpen,
    this.rawRightEyeOpen,
    this.rawHeadEulerY,
    this.rawMouthOpenness,
    this.faceBoundingBox,
    this.landmarkPoints,
  });

  final EmotionLabel dominant;
  /// Per-label confidence in range [0, 1], sums approximately to 1 after normalization.
  final Map<EmotionLabel, double> confidences;
  final DateTime capturedAt;

  final double? rawSmileProbability;
  final double? rawLeftEyeOpen;
  final double? rawRightEyeOpen;
  final double? rawHeadEulerY;
  final double? rawMouthOpenness;

  /// Normalized preview coordinates (0–1) when available.
  final ({double left, double top, double width, double height})? faceBoundingBox;
  final List<({double x, double y})>? landmarkPoints;

  double confidenceFor(EmotionLabel label) =>
      confidences[label]?.clamp(0.0, 1.0) ?? 0.0;

  EmotionData copyWith({
    EmotionLabel? dominant,
    Map<EmotionLabel, double>? confidences,
    DateTime? capturedAt,
    double? rawSmileProbability,
    double? rawLeftEyeOpen,
    double? rawRightEyeOpen,
    double? rawHeadEulerY,
    double? rawMouthOpenness,
    ({double left, double top, double width, double height})? faceBoundingBox,
    List<({double x, double y})>? landmarkPoints,
  }) {
    return EmotionData(
      dominant: dominant ?? this.dominant,
      confidences: confidences ?? Map.from(this.confidences),
      capturedAt: capturedAt ?? this.capturedAt,
      rawSmileProbability: rawSmileProbability ?? this.rawSmileProbability,
      rawLeftEyeOpen: rawLeftEyeOpen ?? this.rawLeftEyeOpen,
      rawRightEyeOpen: rawRightEyeOpen ?? this.rawRightEyeOpen,
      rawHeadEulerY: rawHeadEulerY ?? this.rawHeadEulerY,
      rawMouthOpenness: rawMouthOpenness ?? this.rawMouthOpenness,
      faceBoundingBox: faceBoundingBox ?? this.faceBoundingBox,
      landmarkPoints: landmarkPoints ?? this.landmarkPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'dominant': dominant.name,
        'confidences': confidences.map((k, v) => MapEntry(k.name, v)),
        'capturedAt': capturedAt.toIso8601String(),
        'rawSmileProbability': rawSmileProbability,
        'rawLeftEyeOpen': rawLeftEyeOpen,
        'rawRightEyeOpen': rawRightEyeOpen,
        'rawHeadEulerY': rawHeadEulerY,
        'rawMouthOpenness': rawMouthOpenness,
        if (faceBoundingBox != null)
          'faceBoundingBox': {
            'left': faceBoundingBox!.left,
            'top': faceBoundingBox!.top,
            'width': faceBoundingBox!.width,
            'height': faceBoundingBox!.height,
          },
        if (landmarkPoints != null)
          'landmarkPoints': landmarkPoints!
              .map((p) => {'x': p.x, 'y': p.y})
              .toList(),
      };

  static EmotionData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final dominantName = json['dominant'] as String?;
    if (dominantName == null) return null;
    final dominant = EmotionLabel.values.firstWhere(
      (e) => e.name == dominantName,
      orElse: () => EmotionLabel.neutral,
    );
    final confMap = <EmotionLabel, double>{};
    final raw = json['confidences'] as Map<String, dynamic>?;
    if (raw != null) {
      for (final e in EmotionLabel.values) {
        final v = raw[e.name];
        if (v is num) confMap[e] = v.toDouble();
      }
    }
    return EmotionData(
      dominant: dominant,
      confidences: confMap,
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
          DateTime.now(),
      rawSmileProbability: (json['rawSmileProbability'] as num?)?.toDouble(),
      rawLeftEyeOpen: (json['rawLeftEyeOpen'] as num?)?.toDouble(),
      rawRightEyeOpen: (json['rawRightEyeOpen'] as num?)?.toDouble(),
      rawHeadEulerY: (json['rawHeadEulerY'] as num?)?.toDouble(),
      rawMouthOpenness: (json['rawMouthOpenness'] as num?)?.toDouble(),
    );
  }
}
