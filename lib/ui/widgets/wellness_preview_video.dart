import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Inline autoplay preview for the Flutter docs sample clip (HTTPS).
class WellnessPreviewVideo extends StatefulWidget {
  const WellnessPreviewVideo({
    super.key,
    this.compact = false,
    this.borderRadius = 18,
  });

  final bool compact;
  final double borderRadius;

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
    _init();
  }

  Future<void> _init() async {
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
        child: _failed
            ? _fallback(scheme, 'Preview unavailable (offline or blocked).')
            : (_controller == null || !_controller!.value.isInitialized)
                ? Container(
                    alignment: Alignment.center,
                    color: scheme.surfaceContainerHighest.withOpacity(0.45),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
      ),
    );
  }

  Widget _fallback(ColorScheme scheme, String msg) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      color: scheme.surfaceContainerHighest.withOpacity(0.55),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
