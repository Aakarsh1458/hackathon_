import 'dart:math';

import 'package:flutter/material.dart';

import '../models/time_series_point.dart';

class TrendLineChart extends StatelessWidget {
  final List<TimeSeriesPoint> points;
  final Color accent;
  final double height;

  const TrendLineChart({
    super.key,
    required this.points,
    required this.accent,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withValues(alpha: 0.55);
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: CustomPaint(
        painter: _TrendPainter(points: points, accent: accent),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<TimeSeriesPoint> points;
  final Color accent;

  _TrendPainter({required this.points, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final p = points.toList(growable: false)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (p.length < 2) {
      _drawEmpty(canvas, size);
      return;
    }

    final values = p.map((e) => e.value).toList(growable: false);
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final range = max(1e-6, maxV - minV);

    final pad = 6.0;
    final w = size.width;
    final h = size.height;

    final toOffset = (int i) {
      final x = pad + (w - pad * 2) * (i / (p.length - 1));
      final norm = (p[i].value - minV) / range;
      final y = pad + (h - pad * 2) * (1 - norm);
      return Offset(x, y);
    };

    final path = Path()..moveTo(toOffset(0).dx, toOffset(0).dy);
    for (var i = 1; i < p.length; i++) {
      final o = toOffset(i);
      path.lineTo(o.dx, o.dy);
    }

    final fill = Path.from(path)
      ..lineTo(toOffset(p.length - 1).dx, h - pad)
      ..lineTo(toOffset(0).dx, h - pad)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0.25),
          accent.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.9);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final dotBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.95);

    for (var i = 0; i < p.length; i += max(1, (p.length / 10).floor())) {
      final o = toOffset(i);
      canvas.drawCircle(o, 3.2, dotPaint);
      canvas.drawCircle(o, 3.2, dotBorder);
    }
  }

  void _drawEmpty(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.10);
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    canvas.drawRRect(r, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.accent != accent;
  }
}

