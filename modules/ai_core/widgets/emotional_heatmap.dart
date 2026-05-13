import 'dart:math';

import 'package:flutter/material.dart';

/// Lightweight heatmap grid for "vulnerable time periods" visualization.
/// Values should be 0..1 (higher = more intense/negative frequency indicator).
class EmotionalHeatmap extends StatelessWidget {
  final List<List<double>> matrix;
  final List<String> xLabels;
  final List<String> yLabels;

  const EmotionalHeatmap({
    super.key,
    required this.matrix,
    this.xLabels = const [],
    this.yLabels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final rows = matrix.length;
    final cols = rows == 0 ? 0 : matrix.first.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emotional heatmap',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (rows == 0 || cols == 0)
            Text(
              'No heatmap data yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.72)),
            )
          else
            AspectRatio(
              aspectRatio: cols / max(1, rows),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, i) {
                  final r = i ~/ cols;
                  final c = i % cols;
                  final v = matrix[r][c].clamp(0, 1).toDouble();
                  final color = Color.lerp(
                    const Color(0xFF1F2A44),
                    const Color(0xFFF87171),
                    v,
                  )!;
                  return Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

