import 'package:flutter/material.dart';

import '../models/emotion_data.dart';
import '../models/emotion_label.dart';

class EmotionConfidenceStrip extends StatelessWidget {
  const EmotionConfidenceStrip({
    super.key,
    required this.data,
  });

  final EmotionData? data;

  @override
  Widget build(BuildContext context) {
    final d = data;
    if (d == null) {
      return Text(
        'Position your face in the frame for live expression signals.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
      );
    }
    final ordered = EmotionLabel.values.toList()
      ..sort((a, b) => d.confidenceFor(b).compareTo(d.confidenceFor(a)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dominant signal: ${d.dominant.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        ...ordered.map((label) {
          final v = d.confidenceFor(label);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  child: Text(
                    label.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: v.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _colorFor(label),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(v * 100).round()}%',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _colorFor(EmotionLabel label) {
    switch (label) {
      case EmotionLabel.happy:
        return const Color(0xFF7CF29A);
      case EmotionLabel.sad:
        return const Color(0xFF6FA8FF);
      case EmotionLabel.angry:
        return const Color(0xFFFF8A7A);
      case EmotionLabel.neutral:
        return const Color(0xFFB0B7C3);
      case EmotionLabel.surprised:
        return const Color(0xFFFFD27F);
      case EmotionLabel.stressed:
        return const Color(0xFFD0A3FF);
    }
  }
}
