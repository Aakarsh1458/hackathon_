import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Thin wrapper around ML Kit face detection for testability and isolation.
class FaceDetectionService {
  FaceDetectionService({FaceDetector? detector})
      : _detector = detector ??
            FaceDetector(
              options: FaceDetectorOptions(
                enableContours: false,
                enableLandmarks: true,
                enableClassification: true,
                enableTracking: true,
                minFaceSize: 0.12,
                performanceMode: FaceDetectorMode.fast,
              ),
            );

  final FaceDetector _detector;

  Future<List<Face>> detect(InputImage image) => _detector.processImage(image);

  Future<void> dispose() => _detector.close();
}
