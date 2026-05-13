import '../chat/chat_models.dart';

/// Detects crisis intent keywords in raw user text.
///
/// IMPORTANT: This is NOT a clinical assessment. It's only a safety
/// guardrail for severe language that should trigger escalation messaging.
class CrisisGuard {
  CrisisGuard({List<String>? severeKeywords})
      : _severeKeywords = severeKeywords ??
            const [
              'suicide',
              'kill myself',
              'end my life',
              'self harm',
              'self-harm',
              'hurt myself',
              'harm myself',
              'overdose',
              'i want to die',
              "can't go on",
              'immediate danger',
            ];

  final List<String> _severeKeywords;

  CrisisCheckResult check(String userText) {
    final lower = userText.toLowerCase();
    final matched = <String>[];
    for (final k in _severeKeywords) {
      if (lower.contains(k)) {
        matched.add(k);
      }
    }

    final isCrisis = matched.isNotEmpty;
    return CrisisCheckResult(isCrisis: isCrisis, matchedKeywords: matched);
  }
}

class CrisisCheckResult {
  const CrisisCheckResult({
    required this.isCrisis,
    required this.matchedKeywords,
  });

  final bool isCrisis;
  final List<String> matchedKeywords;
}

/// Centralized safe escalation messaging generator.
class CrisisEscalation {
  const CrisisEscalation();

  String safeCrisisResponse() {
    return 'I’m really sorry you’re feeling this way. I can’t provide emergency help or medical guidance, but I can help you get support right now.\n\n'
        'If you’re in immediate danger or might act on these thoughts, please call your local emergency number right now.\n'
        'If you can, reach out to a trusted person nearby and tell them you need support.\n'
        'If possible, also consider contacting a local crisis hotline or a mental health professional in your area.\n\n'
        'If you want, tell me: are you somewhere safe at the moment?';
  }

  List<WellnessRecommendation> crisisRecommendations() {
    return const [
      WellnessRecommendation(
        title: 'Contact trusted support now',
        body: 'Consider reaching out to someone you trust nearby or a local support line immediately.',
        severity: 2,
        category: 'crisis',
      ),
      WellnessRecommendation(
        title: 'Create immediate safety',
        body: 'If you can, move toward a safer environment and reduce access to anything that could be used to harm yourself.',
        severity: 2,
        category: 'safety',
      ),
      WellnessRecommendation(
        title: 'Grounding while you connect',
        body: 'Try a slow breathing cycle: inhale 4 seconds, exhale 6 seconds for 3 rounds—just to help you steady for the next step.',
        severity: 1,
        category: 'grounding',
      ),
    ];
  }
}

