import 'package:flutter/material.dart';

class MicButton extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final VoidCallback? onTap;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isSpeaking,
    this.onTap,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening || widget.isSpeaking) {
      _c.repeat(reverse: true);
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isListening
        ? const Color(0xFF06B6D4)
        : (widget.isSpeaking ? const Color(0xFF7C3AED) : const Color(0xFF22C55E));

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final glow = 0.20 + 0.18 * _c.value;
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  base.withValues(alpha: 0.95),
                  base.withValues(alpha: 0.55),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  spreadRadius: 2,
                  color: base.withValues(alpha: glow),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(
              widget.isListening ? Icons.graphic_eq : Icons.mic_rounded,
              color: Colors.white,
              size: 30,
            ),
          );
        },
      ),
    );
  }
}

