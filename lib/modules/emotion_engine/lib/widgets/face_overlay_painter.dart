import 'package:flutter/material.dart';

import '../models/emotion_data.dart';

/// Draws normalized face box + landmark dots over the camera preview.
class FaceOverlayPainter extends CustomPainter {
  FaceOverlayPainter({
    required this.emotion,
    this.strokeColor = const Color(0xFF7EE8FA),
    this.landmarkColor = const Color(0xFFB388FF),
  });

  final EmotionData? emotion;
  final Color strokeColor;
  final Color landmarkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final data = emotion;
    if (data?.faceBoundingBox == null) return;
    final box = data!.faceBoundingBox!;
    final rect = Rect.fromLTWH(
      box.left * size.width,
      box.top * size.height,
      box.width * size.width,
      box.height * size.height,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = strokeColor.withValues(alpha: 0.95);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = strokeColor.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      glow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      paint,
    );

    final lm = data.landmarkPoints;
    if (lm == null) return;
    final dot = Paint()..color = landmarkColor.withValues(alpha: 0.85);
    for (final p in lm) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        2.2,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.emotion != emotion;
  }
}
