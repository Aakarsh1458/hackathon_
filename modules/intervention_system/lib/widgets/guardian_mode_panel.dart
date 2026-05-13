import 'package:flutter/material.dart';

import '../models/guardian_mode.dart';

class GuardianModePanel extends StatelessWidget {
  const GuardianModePanel({
    super.key,
    required this.mode,
  });

  final GuardianMode mode;

  @override
  Widget build(BuildContext context) {
    if (!mode.enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Guardian pause',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(mode.gentlePrompt, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Take ${mode.pauseSeconds}s before continuing.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
