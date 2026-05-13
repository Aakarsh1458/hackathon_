import 'package:flutter/material.dart';

/// Circular pill control shared by shell overlays and full-screen flows.
class EdgeNavButton extends StatelessWidget {
  const EdgeNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withOpacity(0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 28,
            color: onPressed == null
                ? scheme.onSurfaceVariant.withOpacity(0.35)
                : scheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Left/right affordances for linear navigation (used outside the shell).
class PageEdgeNavigation extends StatelessWidget {
  const PageEdgeNavigation({
    super.key,
    required this.child,
    required this.onBack,
    required this.onForward,
    this.canGoBack = true,
    this.canGoForward = true,
  });

  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool canGoBack;
  final bool canGoForward;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: EdgeNavButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: canGoBack ? onBack : null,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: EdgeNavButton(
                    icon: Icons.chevron_right_rounded,
                    onPressed: canGoForward ? onForward : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
