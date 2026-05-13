import '../chat/chat_models.dart';

/// Builds system/user prompts for the wellness support chatbot.
///
/// This is where “personality” + safety instructions live. It is intentionally
/// separated from transport/provider logic.
class WellnessPromptBuilder {
  const WellnessPromptBuilder();

  String buildSystemPrompt({required bool crisisMode}) {
    // Keep instructions short and explicit to reduce unpredictable behavior.
    return crisisMode
        ? 'You are a calm wellness support assistant. The user may be in severe distress.\n'
          'Do NOT provide medical advice or diagnosis.\n'
          'Do NOT claim to be a therapist.\n'
          'Encourage the user to contact trusted help immediately and use local emergency services if in immediate danger.\n'
          'Use supportive, non-judgmental language. Keep it grounded and practical.\n'
        : 'You are a calm wellness support assistant focused on emotional recovery and burnout prevention.\n'
          'You are NOT a therapist. Do NOT provide medical advice or diagnosis.\n'
          'Avoid fake certainty and toxic positivity.\n'
          'Use non-judgmental language, validate feelings, and offer grounding, reflection, journaling prompts, and gentle next steps.\n'
          'If the user expresses self-harm or emergency intent, switch to crisis guidance.\n';
  }

  String buildUserPrompt({
    required String userText,
    required EmotionalContext context,
    required bool crisisMode,
  }) {
    final parts = <String>[];
    parts.add('User message: "$userText"');

    if (!crisisMode) {
      final snippet = buildEmotionalContextSnippet(context);
      parts.add('Current wellness context (may be incomplete):\n$snippet');
    } else {
      parts.add('Crisis guidance is required. Stay supportive and encourage immediate help.');
    }

    parts.add(
      'Respond with:\n'
      '1) A brief supportive acknowledgement.\n'
      '2) 1-2 grounding suggestions OR a short calming exercise.\n'
      '3) 1 journaling prompt.\n'
      '4) If appropriate, 1 gentle recovery habit.\n'
      'Keep it short, emotionally safe, and never over-medicalize.\n',
    );

    return parts.join('\n\n');
  }

  String buildEmotionalContextSnippet(EmotionalContext context) {
    String fmtInt(String name, int? v, {String? suffix}) {
      if (v == null) return '$name: unknown';
      final s = suffix == null ? '' : suffix;
      return '$name: $v$s';
    }

    String fmtDouble01(String name, double? v) {
      if (v == null) return '$name: unknown';
      final pct = (v * 100).round();
      return '$name: $pct%';
    }

    final lines = <String>[
      fmtInt('wellnessScore (0..100)', context.wellnessScore),
      fmtInt('stressIndex (0..100)', context.stressIndex),
      fmtDouble01('recoveryProgress (0..1)', context.recoveryProgress),
      fmtInt('burnoutIndicators', context.burnoutIndicators),
      if (context.relapseRisk == null)
        'relapseRisk: unknown'
      else
        'relapseRisk: ${(context.relapseRisk! * 100).round()}%',
      if (context.emotionalTrends == null || context.emotionalTrends!.isEmpty)
        'emotionalTrends: none provided'
      else
        'emotionalTrends: ${context.emotionalTrends!.join(', ')}',
      if (context.journalingHints == null || context.journalingHints!.isEmpty)
        'journalingHints: none provided'
      else
        'journalingHints: ${context.journalingHints}',
    ];

    return lines.join('\n');
  }
}

