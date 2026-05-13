import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Maps device + sensor orientation to ML Kit [InputImageRotation].
InputImageRotation computeInputImageRotation({
  required CameraDescription description,
  required DeviceOrientation deviceOrientation,
}) {
  var rotation = description.sensorOrientation;
  if (description.lensDirection == CameraLensDirection.front) {
    rotation = (rotation + 360 - 90) % 360;
  }
  var compensation = 0;
  switch (deviceOrientation) {
    case DeviceOrientation.portraitUp:
      compensation = 0;
      break;
    case DeviceOrientation.landscapeLeft:
      compensation = 90;
      break;
    case DeviceOrientation.portraitDown:
      compensation = 180;
      break;
    case DeviceOrientation.landscapeRight:
      compensation = 270;
      break;
  }
  final total = (rotation + compensation) % 360;
  return InputImageRotationValue.fromRawValue(total) ??
      InputImageRotation.rotation0deg;
}

/// Converts a [CameraImage] to [InputImage] for on-device face analysis.
InputImage? inputImageFromCameraImage({
  required CameraImage image,
  required InputImageRotation rotation,
}) {
  if (kIsWeb) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  final planeData = image.planes
      .map(
        (p) => InputImagePlaneMetadata(
          bytesPerRow: p.bytesPerRow,
          height: p.height,
          width: p.width,
        ),
      )
      .toList();

  final buffer = WriteBuffer();
  for (final plane in image.planes) {
    buffer.putUint8List(plane.bytes);
  }
  final bytes = buffer.done().buffer.asUint8List();

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      planeData: planeData,
    ),
  );
}
