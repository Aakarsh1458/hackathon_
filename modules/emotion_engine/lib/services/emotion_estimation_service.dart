import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/emotion_data.dart';
import '../models/emotion_label.dart';
import '../utils/emotion_math_utils.dart';

/// Maps ML Kit face metrics + landmarks to wellness-oriented expression signals.
class EmotionEstimationService {
  const EmotionEstimationService();

  EmotionData estimate(
    Face face,
    int imageWidth,
    int imageHeight,
  ) {
    final smile = face.smilingProbability ?? 0.0;
    final leftEye = face.leftEyeOpenProbability ?? 0.5;
    final rightEye = face.rightEyeOpenProbability ?? 0.5;
    final avgEye = (leftEye + rightEye) / 2;
    final headY = face.headEulerAngleY;
    final headZ = face.headEulerAngleZ;

    final w = face.boundingBox.width.clamp(1.0, double.infinity);
    final mouthOpen = _mouthOpennessNorm(face, w);
    final mouthDroop = _mouthCornerDroop(face, w);

    final raw = <EmotionLabel, double>{
      EmotionLabel.happy: _happyScore(smile, mouthOpen, mouthDroop),
      EmotionLabel.sad: _sadScore(smile, mouthDroop, avgEye),
      EmotionLabel.angry: _angryScore(headY, headZ, smile, mouthDroop),
      EmotionLabel.neutral: _neutralScore(smile, mouthOpen, mouthDroop, avgEye),
      EmotionLabel.surprised: _surprisedScore(mouthOpen, avgEye, smile),
      EmotionLabel.stressed: _stressedScore(smile, avgEye, headZ, mouthDroop),
    };

    final confidences = normalizeScores(raw);
    final dominant = dominantFrom(confidences);

    final box = face.boundingBox;
    final normBox = (
      left: (box.left / imageWidth).clamp(0.0, 1.0),
      top: (box.top / imageHeight).clamp(0.0, 1.0),
      width: (box.width / imageWidth).clamp(0.0, 1.0),
      height: (box.height / imageHeight).clamp(0.0, 1.0),
    );

    final landmarks = <({double x, double y})>[];
    for (final Object? lm in face.landmarks.values) {
      if (lm is! FaceLandmark) continue;
      landmarks.add((
        x: (lm.position.x / imageWidth).clamp(0.0, 1.0),
        y: (lm.position.y / imageHeight).clamp(0.0, 1.0),
      ));
    }

    return EmotionData(
      dominant: dominant,
      confidences: confidences,
      capturedAt: DateTime.now(),
      rawSmileProbability: smile,
      rawLeftEyeOpen: leftEye,
      rawRightEyeOpen: rightEye,
      rawHeadEulerY: headY,
      rawMouthOpenness: mouthOpen,
      faceBoundingBox: normBox,
      landmarkPoints: landmarks.isEmpty ? null : List.unmodifiable(landmarks),
    );
  }

  double _mouthOpennessNorm(Face face, double faceWidth) {
    final bottom = face.landmarks[FaceLandmarkType.bottomMouth];
    final left = face.landmarks[FaceLandmarkType.leftMouth];
    final right = face.landmarks[FaceLandmarkType.rightMouth];
    if (bottom == null || left == null || right == null) return 0.0;
    final midY = (left.position.y + right.position.y) / 2;
    return ((bottom.position.y - midY) / faceWidth).clamp(0.0, 1.4);
  }

  /// Positive when mouth corners sit lower relative to nose (signal heuristic).
  double _mouthCornerDroop(Face face, double faceWidth) {
    final nose = face.landmarks[FaceLandmarkType.noseBase];
    final left = face.landmarks[FaceLandmarkType.leftMouth];
    final right = face.landmarks[FaceLandmarkType.rightMouth];
    if (nose == null || left == null || right == null) return 0.0;
    final cornerY = (left.position.y + right.position.y) / 2;
    return ((cornerY - nose.position.y) / faceWidth).clamp(-0.5, 0.8);
  }

  double _happyScore(double smile, double mouthOpen, double droop) {
    return smile * 2.2 - (droop * 1.4) + (mouthOpen * 0.15);
  }

  double _sadScore(double smile, double droop, double eyeOpen) {
    return droop * 2.0 - smile * 1.8 + (0.45 - eyeOpen) * 0.6;
  }

  double _angryScore(double? headY, double? headZ, double smile, double droop) {
    final yaw = (headY ?? 0).abs() / 40.0;
    final tilt = (headZ ?? 0).abs() / 35.0;
    return yaw + tilt - smile * 1.2 + droop * 0.8;
  }

  double _neutralScore(
    double smile,
    double mouthOpen,
    double droop,
    double eyeOpen,
  ) {
    final intensity = smile + mouthOpen + droop.abs() + (eyeOpen - 0.5).abs();
    return 1.6 - intensity;
  }

  double _surprisedScore(double mouthOpen, double eyeOpen, double smile) {
    return mouthOpen * 2.1 + (eyeOpen - 0.35).clamp(0.0, 0.65) * 1.4 - smile * 0.4;
  }

  double _stressedScore(
    double smile,
    double eyeOpen,
    double? headZ,
    double droop,
  ) {
    final tension = (headZ ?? 0).abs() / 45.0;
    return tension + (0.55 - smile) * 1.1 + (eyeOpen - 0.42).abs() * 0.9 + droop * 0.5;
  }
}
