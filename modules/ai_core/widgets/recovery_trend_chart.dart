import 'package:flutter/material.dart';

import '../models/time_series_point.dart';
import 'trend_line_chart.dart';

/// Convenience wrapper for a recovery-oriented chart (sleep/rest/connection proxies).
class RecoveryTrendChart extends StatelessWidget {
  final List<TimeSeriesPoint> points;
  const RecoveryTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return TrendLineChart(
      points: points,
      accent: const Color(0xFF22C55E),
      height: 130,
    );
  }
}

