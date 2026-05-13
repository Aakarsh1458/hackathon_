import 'package:flutter/material.dart';

import '../models/mood_timeline.dart';
import '../services/emotion_service.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/mood_timeline_chart.dart';
import 'journal_screen.dart';
import 'live_emotion_screen.dart';

/// Module home: summaries, timeline, and entry points to live + journal flows.
class EmotionDashboardScreen extends StatelessWidget {
  const EmotionDashboardScreen({
    super.key,
    required this.service,
  });

  final EmotionService service;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final state = service.signalState;
        final timeline = state.timeline ??
            MoodTimeline(
              entries: const [],
              faceSignals: const [],
              generatedAt: DateTime.now(),
            );
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A0E15),
                Color(0xFF101827),
                Color(0xFF0F1722),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signal studio',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Live expression estimation, journaling, and gentle wellness indicators.',
                    style: TextStyle(color: Colors.white60, height: 1.35),
                  ),
                  if (state.lastError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.lastError!,
                      style: const TextStyle(color: Color(0xFFFFB4A8)),
                    ),
                  ],
                  const SizedBox(height: 18),
                  MoodSummaryCard(state: state),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _GlowButton(
                          label: 'Live signals',
                          icon: Icons.videocam_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LiveEmotionScreen(service: service),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlowButton(
                          label: 'Journal',
                          icon: Icons.edit_note_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => JournalScreen(service: service),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Daily emotional trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: MoodTimelineChart(timeline: timeline),
                  ),
                  const SizedBox(height: 16),
                  if (state.wellnessIndicators.isNotEmpty) ...[
                    Text(
                      'Wellness indicators',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final kv in state.wellnessIndicators.entries)
                          Chip(
                            label: Text(
                              '${kv.key}: ${(kv.value * 100).round()}%',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFF1B2433),
                            side: const BorderSide(color: Colors.white12),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1C2535),
                Color(0xFF141B28),
              ],
            ),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7EE8FA).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF7EE8FA)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
