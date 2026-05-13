import 'package:flutter/material.dart';

/// Lightweight “preview” strip (no `video_player` dependency).
///
/// Shows a poster-style frame; tap opens the Flutter docs sample clip in the
/// default browser via [url_launcher]-free approach: copy-friendly label only.
/// For a real inline player, add `video_player` and run `flutter pub get`.
class WellnessPreviewVideo extends StatelessWidget {
  const WellnessPreviewVideo({
    super.key,
    this.compact = false,
    this.borderRadius = 18,
  });

  static const demoVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  final bool compact;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final h = compact ? 160.0 : 220.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withOpacity(0.55),
                scheme.surfaceContainerHighest.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Avoid url_launcher dependency; show where the clip lives.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sample clip: $demoVideoUrl'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill_rounded,
                      size: compact ? 52 : 64,
                      color: scheme.primary.withOpacity(0.92),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Product preview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Tap for sample video URL (add video_player for inline playback).',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
