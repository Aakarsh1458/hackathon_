import '../models/chat_message.dart';

enum SafetySeverity { none, caution, crisis }

class SafetyResult {
  final SafetySeverity severity;
  final List<String> matchedKeywords;
  final String? safeResponse;
  final List<String> suggestions;

  const SafetyResult({
    required this.severity,
    this.matchedKeywords = const [],
    this.safeResponse,
    this.suggestions = const [],
  });
}

/// Lightweight, keyword-based safety filter.
///
/// Not a substitute for professional care. Used for escalation suggestions and
/// supportive fallback responses.
class SafetyGuardrails {
  final Set<String> crisisKeywords;
  final Set<String> cautionKeywords;

  const SafetyGuardrails({
    this.crisisKeywords = const {
      'suicide',
      'kill myself',
      'end it',
      'self harm',
      'self-harm',
      'hurt myself',
      'overdose',
      'i want to die',
    },
    this.cautionKeywords = const {
      'relapse',
      'craving',
      'drink',
      'use',
      'panic',
      'can’t cope',
      'cant cope',
      'hopeless',
      'alone',
    },
  });

  SafetyResult evaluateUserText(String text) {
    final t = text.toLowerCase();

    final crisis = crisisKeywords.where((k) => t.contains(k)).toList(growable: false);
    if (crisis.isNotEmpty) {
      return SafetyResult(
        severity: SafetySeverity.crisis,
        matchedKeywords: crisis,
        safeResponse:
            "I’m really sorry you’re feeling this way. I can’t provide crisis help, but you deserve immediate support. "
            "If you’re in danger or might hurt yourself, please contact local emergency services now. "
            "If you can, reach out to someone you trust and stay with them while you get help.",
        suggestions: const [
          'Contact local emergency services if you’re in immediate danger',
          'Reach out to a trusted person right now',
          'If available in your area, call a crisis hotline',
        ],
      );
    }

    final caution = cautionKeywords.where((k) => t.contains(k)).toList(growable: false);
    if (caution.isNotEmpty) {
      return SafetyResult(
        severity: SafetySeverity.caution,
        matchedKeywords: caution,
        safeResponse:
            "I hear you. I’m not a therapist, but I can help you slow things down and choose a next step that supports recovery. "
            "Would you like a quick grounding exercise, or help naming the trigger and a safer alternative?",
        suggestions: const [
          'Try a short grounding exercise',
          'Name the trigger and one small safer action',
          'Consider reaching out to a support person/group',
        ],
      );
    }

    return const SafetyResult(severity: SafetySeverity.none);
  }

  /// Ensures assistant responses avoid dependency/claims and remain non-clinical.
  ChatMessage sanitizeAssistantMessage(ChatMessage m) {
    var c = m.content;
    c = c.replaceAll(RegExp(r"\bI am your therapist\b", caseSensitive: false), "I’m a wellness support assistant");
    c = c.replaceAll(RegExp(r"\bdiagnos(e|is)\b", caseSensitive: false), "assess");
    return ChatMessage(
      id: m.id,
      role: m.role,
      content: c,
      timestamp: m.timestamp,
      meta: m.meta,
    );
  }
}

