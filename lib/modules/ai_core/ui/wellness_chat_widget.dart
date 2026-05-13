import 'package:flutter/material.dart';

import '../chat/chat_models.dart';
import '../recommendations/recommendation_engine.dart';
import '../safety/crisis_guard.dart';
import '../services/wellness_chat_service.dart';
import 'chat_bubble.dart';
import 'thinking_indicator.dart';
import 'typing_indicator.dart';
import 'recovery_recommendation_card.dart';

/// Modular chat UI widget for the AI Core module.
///
/// It does NOT own or run emotion detection. It consumes upstream
/// [EmotionalContext] provided via constructor.
class WellnessChatWidget extends StatefulWidget {
  const WellnessChatWidget({
    super.key,
    required this.chatService,
    required this.context,
    this.enableStreamingThinking = true,
  });

  final WellnessChatService chatService;
  final EmotionalContext context;
  final bool enableStreamingThinking;

  @override
  State<WellnessChatWidget> createState() => _WellnessChatWidgetState();
}

class _WellnessChatWidgetState extends State<WellnessChatWidget> {
  final _controller = TextEditingController();
  final _crisisGuard = CrisisGuard();
  final _recommendationEngine = RecommendationEngine();

  final List<ChatMessage> _messages = [];
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _busy = true;
      _messages.add(ChatMessage(role: 'user', content: text));
      _controller.clear();
    });

    final crisisMode = _crisisGuard.check(text).isCrisis;
    final recommendations = _recommendationEngine.build(
      context: widget.context,
      crisisMode: crisisMode,
    );

    try {
      final response = await widget.chatService.sendUserMessage(
        userText: text,
        context: widget.context,
      );

      setState(() {
        _messages.add(response.assistantMessage);
      });
      _showRecommendationsDialog(recommendations);
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content:
                'I’m here with you. Something went wrong while generating my response. Please try again in a moment.',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showRecommendationsDialog(List<WellnessRecommendation> items) {
    if (items.isEmpty) return;
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: RecoveryRecommendationCard(items: items),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Companion'),
        actions: [
          if (_busy)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: widget.enableStreamingThinking
                  ? const ThinkingIndicator(label: 'Thinking')
                  : const SizedBox.shrink(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index < _messages.length) {
                    final m = _messages[index];
                    return ChatBubble(message: m);
                  }
                  // Spacer + typing indicator.
                  return _busy ? const TypingIndicator() : const SizedBox.shrink();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.55),
                border: Border(
                  top: BorderSide(
                    color: scheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type what you’re feeling...',
                        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: scheme.outlineVariant.withOpacity(0.35),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonal(
                    onPressed: _busy ? null : _send,
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

