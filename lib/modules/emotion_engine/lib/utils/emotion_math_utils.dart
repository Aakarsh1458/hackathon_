import 'dart:math' as math;

import '../models/emotion_label.dart';

/// Softmax-like normalization so scores form a proper distribution.
Map<EmotionLabel, double> normalizeScores(Map<EmotionLabel, double> raw) {
  final expMap = <EmotionLabel, double>{};
  var sum = 0.0;
  for (final e in EmotionLabel.values) {
    final v = raw[e] ?? 0.0;
    final ev = math.exp(v.clamp(-8.0, 8.0));
    expMap[e] = ev;
    sum += ev;
  }
  if (sum <= 1e-9) {
    return {for (final e in EmotionLabel.values) e: 1.0 / EmotionLabel.values.length};
  }
  return {for (final e in EmotionLabel.values) e: (expMap[e] ?? 0.0) / sum};
}

EmotionLabel dominantFrom(Map<EmotionLabel, double> confidences) {
  EmotionLabel best = EmotionLabel.neutral;
  var max = -1.0;
  for (final e in EmotionLabel.values) {
    final c = confidences[e] ?? 0.0;
    if (c > max) {
      max = c;
      best = e;
    }
  }
  return best;
}
