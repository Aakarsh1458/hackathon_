import '../models/emotion_data.dart';
import '../models/emotion_label.dart';

/// Demo-safe estimator stub.
///
/// Host app can replace with ML Kit integration once dependencies are added.
class EmotionEstimationService {
  const EmotionEstimationService();

  EmotionData estimate(
    Object face,
    int imageWidth,
    int imageHeight,
  ) {
    // Neutral placeholder.
    return EmotionData(
      dominant: EmotionLabel.neutral,
      confidences: const {
        EmotionLabel.neutral: 1.0,
      },
      capturedAt: DateTime.now(),
    );
  }
}
