import 'dart:math';

import 'package:flutter/material.dart';

/// Subtle typing indicator (calm animation, no heavy shaders).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _wave(int i) {
    // Phase shift each dot.
    final t = (_controller.value + i * 0.18) % 1.0;
    final s = (sin(t * 2 * pi) + 1) / 2; // 0..1
    return 0.25 + s * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final v = _wave(i);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withOpacity(v),
            ),
          ),
        );
      }),
    );
  }
}

