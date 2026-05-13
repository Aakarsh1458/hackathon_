import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/emotional_context.dart';
import '../providers/voice_assistant_controller.dart';
import '../providers/voice_assistant_providers.dart';
import '../services/voice_conversation_service.dart';
import '../widgets/chat_timeline.dart';
import '../widgets/mic_button.dart';
import '../widgets/voice_wave_indicator.dart';

/// Standalone voice assistant surface the host app can embed anywhere.
/// No routing assumptions. STT/TTS + chat service are injected via providers.
class VoiceWellnessAssistantScreen extends ConsumerWidget {
  const VoiceWellnessAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(voiceAssistantControllerProvider);
    final ctx = ref.watch(currentEmotionalContextProvider);
    final state = controller.state;

    final isListening = state == VoiceTurnState.listening;
    final isSpeaking = state == VoiceTurnState.speaking;

    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF111A2F), Color(0xFF070A12)],
              center: Alignment.topLeft,
              radius: 1.3,
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice wellness assistant',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A calm conversational companion for grounding and recovery support (not therapy, not diagnosis).',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        state: state,
                        partial: controller.partialTranscript,
                        context: ctx,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ChatTimeline(messages: controller.timeline),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isListening ? 'Listening…' : (isSpeaking ? 'Speaking…' : 'Tap the mic to talk'),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.90),
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              VoiceWaveIndicator(
                                active: isListening || isSpeaking,
                                accent: isListening ? const Color(0xFF06B6D4) : const Color(0xFF7C3AED),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      MicButton(
                        isListening: isListening,
                        isSpeaking: isSpeaking,
                        onTap: () async {
                          final c = ref.read(voiceAssistantControllerProvider);
                          if (c.state == VoiceTurnState.listening) {
                            await c.stopListening();
                          } else {
                            await c.startListening(context: ctx);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final VoiceTurnState state;
  final String partial;
  final EmotionalContext context;

  const _StatusRow({
    required this.state,
    required this.partial,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final s = switch (state) {
      VoiceTurnState.idle => 'Idle',
      VoiceTurnState.listening => 'Listening',
      VoiceTurnState.thinking => 'Thinking',
      VoiceTurnState.speaking => 'Speaking',
      VoiceTurnState.error => 'Error',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'State: $s',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
              ),
              const Spacer(),
              Text(
                'Stress ${context.stressScore.round()}/100',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          if (partial.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              partial,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

