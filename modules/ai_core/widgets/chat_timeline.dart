import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatTimeline extends StatelessWidget {
  final List<ChatMessage> messages;
  const ChatTimeline({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    final items = messages.where((m) => m.role != ChatRole.system).toList(growable: false);
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          'No conversation yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.72)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final m = items[i];
        final isUser = m.role == ChatRole.user;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isUser
                    ? [const Color(0xFF0EA5E9).withValues(alpha: 0.22), const Color(0xFF111827).withValues(alpha: 0.88)]
                    : [const Color(0xFF7C3AED).withValues(alpha: 0.20), const Color(0xFF111827).withValues(alpha: 0.88)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              m.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.90)),
            ),
          ),
        );
      },
    );
  }
}

