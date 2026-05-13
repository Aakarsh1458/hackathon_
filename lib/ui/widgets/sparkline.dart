import 'dart:math';

import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    this.height = 44,
  });

  final List<double> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: points,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minV = points.reduce(min);
    final maxV = points.reduce(max);
    final span = max(0.0001, maxV - minV);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.95);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.12);

    final path = Path();
    final fillPath = Path();

    Offset p(int i) {
      final t = i / (points.length - 1);
      final x = t * size.width;
      final yN = (points[i] - minV) / span;
      final y = size.height - (yN * size.height);
      return Offset(x, y);
    }

    path.moveTo(p(0).dx, p(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(p(i).dx, p(i).dy);
    }

    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

