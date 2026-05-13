import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Dictation chip for journal — appends recognized text into [controller].
class JournalVoiceBar extends StatefulWidget {
  const JournalVoiceBar({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<JournalVoiceBar> createState() => _JournalVoiceBarState();
}

class _JournalVoiceBarState extends State<JournalVoiceBar> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;
  bool _ready = false;
  String _partial = '';

  Future<void> _toggle() async {
    if (_listening) {
      await _speech.stop();
      setState(() {
        _listening = false;
        _partial = '';
      });
      return;
    }

    _ready = await _speech.initialize(
      onStatus: (_) {},
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech error: $e')),
          );
        }
      },
    );

    if (!_ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not available.')),
        );
      }
      return;
    }

    setState(() {
      _listening = true;
      _partial = '';
    });

    await _speech.listen(
      onResult: (stt.SpeechRecognitionResult r) {
        setState(() => _partial = r.recognizedWords);
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          final t = r.recognizedWords.trim();
          final cur = widget.controller.text.trim();
          widget.controller.text = cur.isEmpty ? t : '$cur $t';
          widget.controller.selection = TextSelection.collapsed(
            offset: widget.controller.text.length,
          );
          _speech.stop();
          setState(() {
            _listening = false;
            _partial = '';
          });
        }
      },
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: _listening ? 'Stop dictation' : 'Speak your journal entry',
          onPressed: _toggle,
          icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _listening
                ? (_partial.isEmpty ? 'Listening…' : _partial)
                : 'Voice',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ),
      ],
    );
  }
}
