import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/emotion_service.dart';
import '../widgets/emotion_camera_preview.dart';

/// Full-bleed live camera + expression signals (mount inside host navigator).
class LiveEmotionScreen extends StatefulWidget {
  const LiveEmotionScreen({
    super.key,
    required this.service,
  });

  final EmotionService service;

  @override
  State<LiveEmotionScreen> createState() => _LiveEmotionScreenState();
}

class _LiveEmotionScreenState extends State<LiveEmotionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.service.ensureCamera();
      if (!mounted) return;
      await widget.service.startLiveAnalysis();
    });
  }

  @override
  void dispose() {
    widget.service.stopLiveAnalysis();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        widget.service.updateOrientation(
          orientation == Orientation.portrait
              ? DeviceOrientation.portraitUp
              : DeviceOrientation.landscapeLeft,
        );
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B0F14),
                Color(0xFF111827),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: EmotionCameraPreview(service: widget.service),
            ),
          ),
        );
      },
    );
  }
}
