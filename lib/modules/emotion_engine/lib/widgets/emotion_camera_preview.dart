import 'package:flutter/material.dart';

import '../services/emotion_service.dart';
import 'emotion_confidence_strip.dart';
import 'face_overlay_painter.dart';

/// Live preview with face box, landmarks, and confidence readout.
class EmotionCameraPreview extends StatelessWidget {
  const EmotionCameraPreview({
    super.key,
    required this.service,
  });

  final EmotionService service;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final live = service.signalState.liveFaceSignal;
        // Demo-safe build: camera is disabled unless host app adds dependencies.
        if (service.cameraController == null) {
          return const Center(
            child: Text(
              'Camera preview unavailable in this demo build.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54),
                  child: Center(
                    child: Text(
                      'Add camera + ML dependencies to enable live preview.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                CustomPaint(
                  painter: FaceOverlayPainter(emotion: live),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _GlassPanel(
                    child: EmotionConfidenceStrip(data: live),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: child,
      ),
    );
  }
}
