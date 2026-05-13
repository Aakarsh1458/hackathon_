import 'package:camera/camera.dart';
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
        final controller = service.cameraController;
        final live = service.signalState.liveFaceSignal;
        if (controller == null || !controller.value.isInitialized) {
          return const Center(
            child: Text(
              'Camera warming up…',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final ar = controller.value.aspectRatio;
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: constraints.maxHeight * ar,
                      height: constraints.maxHeight,
                      child: CameraPreview(controller),
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
