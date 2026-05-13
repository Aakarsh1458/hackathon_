import 'package:flutter/material.dart';

import '../../../../ui/widgets/journal_voice_bar.dart';
import '../../../ai_core/screens/voice_wellness_assistant_screen.dart';
import '../services/emotion_service.dart';
import '../widgets/journal_entry_tile.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.service,
  });

  final EmotionService service;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit({bool linkSignal = true}) async {
    await widget.service.saveJournal(
      _controller.text,
      linkCurrentSignal: linkSignal,
    );
    _controller.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.service,
      builder: (context, _) {
        final entries = widget.service.journalEntries;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B0F14),
                Color(0xFF141C2B),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reflective journaling',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Entries can link to your current facial expression signals for context — not a diagnosis.',
                    style: TextStyle(color: Colors.white54, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What feels present for you right now?',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF171E2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  JournalVoiceBar(controller: _controller),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7EE8FA),
                          foregroundColor: const Color(0xFF0B0F14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                        ),
                        child: const Text('Save entry'),
                      ),
                      TextButton(
                        onPressed: () => _submit(linkSignal: false),
                        child: const Text(
                          'Save without signal',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const VoiceWellnessAssistantScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.record_voice_over_rounded, color: Colors.white70),
                        label: const Text(
                          'Voice assistant',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final e in entries) JournalEntryTile(entry: e),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
