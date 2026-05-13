import 'dart:math';

import 'package:flutter/material.dart';

class VoiceWaveIndicator extends StatefulWidget {
  final bool active;
  final Color accent;
  final double height;

  const VoiceWaveIndicator({
    super.key,
    required this.active,
    required this.accent,
    this.height = 28,
  });

  @override
  State<VoiceWaveIndicator> createState() => _VoiceWaveIndicatorState();
}

class _VoiceWaveIndicatorState extends State<VoiceWaveIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void didUpdateWidget(covariant VoiceWaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _WavePainter(
              t: _c.value,
              accent: widget.accent,
              active: widget.active,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  final Color accent;
  final bool active;

  _WavePainter({required this.t, required this.accent, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: active ? 0.85 : 0.25);

    final midY = size.height / 2;
    final ampBase = active ? size.height * 0.22 : size.height * 0.05;
    final amp = ampBase * (0.65 + 0.35 * sin(t * 2 * pi));

    final path = Path();
    for (var x = 0.0; x <= size.width; x += 6) {
      final phase = (x / size.width) * 2 * pi;
      final y = midY + sin(phase * 2 + t * 2 * pi) * amp;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.accent != accent || oldDelegate.active != active;
  }
}

