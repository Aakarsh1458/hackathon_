import 'package:flutter/material.dart';

/// Soft gradient backdrop for emotionally calm shell surfaces.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.alignBegin = Alignment.topLeft,
    this.alignEnd = Alignment.bottomRight,
  });

  final Widget child;
  final Alignment alignBegin;
  final Alignment alignEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: alignBegin,
          end: alignEnd,
          colors: [
            scheme.surfaceContainerLowest,
            scheme.surfaceContainerLow,
          ],
        ),
      ),
      child: child,
    );
  }
}

