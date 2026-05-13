import 'package:flutter/material.dart';

import '../models/mood_entry.dart';

class JournalEntryTile extends StatelessWidget {
  const JournalEntryTile({
    super.key,
    required this.entry,
  });

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(entry.createdAt).format(context);
    final linked = entry.linkedEmotion?.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171E2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              if (linked != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7EE8FA).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Linked signal: $linked',
                    style: const TextStyle(color: Color(0xFF7EE8FA), fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.body,
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }
}
