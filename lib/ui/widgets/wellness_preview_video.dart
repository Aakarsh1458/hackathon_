import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Inline autoplay preview using Flutter’s public sample clip (network).
/// Audio is muted by default for autoplay-friendly behavior.
class WellnessPreviewVideo extends StatefulWidget {
  const WellnessPreviewVideo({
    super.key,
    this.compact = false,
    this.borderRadius = 18,
  });

  /// Shorter height for secondary placements (tabs, cards).
  final bool compact;
  final double borderRadius;

  /// Stable HTTPS sample used across Flutter documentation demos.
  static const demoVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  State<WellnessPreviewVideo> createState() => _WellnessPreviewVideoState();
}

class _WellnessPreviewVideoState extends State<WellnessPreviewVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(WellnessPreviewVideo.demoVideoUrl));
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
      await c.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final h = widget.compact ? 160.0 : 220.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: _buildInner(scheme),
      ),
    );
  }

  Widget _buildInner(ColorScheme scheme) {
    if (_failed) {
      return Container(
        alignment: Alignment.center,
        color: scheme.surfaceContainerHighest.withOpacity(0.55),
        padding: const EdgeInsets.all(16),
        child: Text(
          'Preview video unavailable (offline or blocked).\n'
          'Connect to the network to stream the demo clip.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return Container(
        alignment: Alignment.center,
        color: scheme.surfaceContainerHighest.withOpacity(0.45),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }
}
