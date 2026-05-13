import 'dart:math';

double clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
double clamp100(double v) => v < 0 ? 0 : (v > 100 ? 100 : v);

double lerp(double a, double b, double t) => a + (b - a) * t;

double safeDiv(double num, double den, {double fallback = 0}) {
  if (den == 0) return fallback;
  return num / den;
}

double mean(Iterable<double> values) {
  final list = values.toList(growable: false);
  if (list.isEmpty) return 0;
  final sum = list.fold<double>(0, (a, b) => a + b);
  return sum / list.length;
}

double stdDev(Iterable<double> values) {
  final list = values.toList(growable: false);
  if (list.length <= 1) return 0;
  final m = mean(list);
  final variance =
      list.map((x) => pow(x - m, 2).toDouble()).reduce((a, b) => a + b) /
          (list.length - 1);
  return sqrt(variance);
}

double expSmooth({
  required double previous,
  required double current,
  required double alpha,
}) {
  final a = clamp01(alpha);
  return previous * (1 - a) + current * a;
}

