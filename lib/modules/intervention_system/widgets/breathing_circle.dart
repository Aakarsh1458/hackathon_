import 'dart:math' as math;

import 'package:flutter/material.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({
    super.key,
    required this.inhaleSeconds,
    required this.exhaleSeconds,
    required this.holdSeconds,
  });

  final int inhaleSeconds;
  final int exhaleSeconds;
  final int holdSeconds;

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      seconds: widget.inhaleSeconds + widget.holdSeconds + widget.exhaleSeconds,
    ),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = 0.85 + (math.sin(_controller.value * math.pi * 2) + 1) * 0.1;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.24), width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.18),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
