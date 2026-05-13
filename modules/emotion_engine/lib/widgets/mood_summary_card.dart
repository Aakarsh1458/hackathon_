import 'package:flutter/material.dart';

import '../models/signal_state.dart';

class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({
    super.key,
    required this.state,
  });

  final SignalState state;

  @override
  Widget build(BuildContext context) {
    final timeline = state.timeline;
    final summary = timeline?.recentSummary(maxEntries: 4) ??
        'Your emotional signals will summarize here over time.';
    final live = state.liveFaceSignal;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B2230),
            Color(0xFF121826),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7EE8FA).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent emotional signals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            live != null
                ? 'Live expression estimate: ${live.dominant.name} · ${(live.confidenceFor(live.dominant) * 100).round()}% confidence'
                : 'No live face signal — open the live view to begin.',
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(color: Colors.white60, height: 1.4),
          ),
        ],
      ),
    );
  }
}
