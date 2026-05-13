import 'package:flutter/material.dart';

/// “Thinking” indicator for the assistant.
class ThinkingIndicator extends StatelessWidget {
  const ThinkingIndicator({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              scheme.primary.withOpacity(0.9),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 10),
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

