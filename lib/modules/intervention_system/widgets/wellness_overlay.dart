import 'package:flutter/material.dart';

import '../models/emotional_environment.dart';

class WellnessOverlay extends StatelessWidget {
  const WellnessOverlay({
    super.key,
    required this.environment,
    this.child,
  });

  final EmotionalEnvironment environment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: (environment.motionPacingSeconds * 1000).round()),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: environment.theme.backgroundGradient,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.1,
                    colors: <Color>[
                      environment.theme.secondary.withOpacity(
                        environment.overlayOpacity * environment.ambientGlow,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
