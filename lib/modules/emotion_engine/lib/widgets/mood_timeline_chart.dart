import 'package:flutter/material.dart';

import '../models/mood_timeline.dart';

/// Minimal sparkline-style timeline for daily emotional trend (wellness indicator).
class MoodTimelineChart extends StatelessWidget {
  const MoodTimelineChart({
    super.key,
    required this.timeline,
  });

  final MoodTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final points = timeline.sortedDailyTrend();
    if (points.isEmpty) {
      return const _EmptyChartCard(
        message: 'Trends appear after you journal or capture live signals.',
      );
    }
    return CustomPaint(
      painter: _TrendPainter(points: points),
      child: const SizedBox.expand(),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.points});

  final List<({DateTime day, double trend})> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final bg = Paint()..color = const Color(0xFF141A24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bg,
    );

    final minV = points.map((p) => p.trend).reduce((a, b) => a < b ? a : b);
    final maxV = points.map((p) => p.trend).reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final t = (points[i].trend - minV) / span;
      final x = size.width * (i / (points.length - 1).clamp(1, 9999));
      final y = size.height - (t * (size.height * 0.72) + size.height * 0.14);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFF7EE8FA).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glow);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7EE8FA);
    canvas.drawPath(path, line);

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7EE8FA).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, gradient);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _EmptyChartCard extends StatelessWidget {
  const _EmptyChartCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
