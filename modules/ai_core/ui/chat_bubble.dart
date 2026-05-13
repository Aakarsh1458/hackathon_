import 'package:flutter/material.dart';

import '../chat/chat_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    final background = isUser
        ? scheme.primary.withOpacity(0.16)
        : scheme.surfaceContainerHighest.withOpacity(0.35);

    final border = Border.all(
      color: scheme.outlineVariant.withOpacity(0.4),
      width: isUser ? 0.5 : 1.0,
    );

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
              bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
            ),
            border: border,
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isUser ? scheme.primary : scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}

