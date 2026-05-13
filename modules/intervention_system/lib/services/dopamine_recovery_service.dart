import '../models/emotional_context.dart';

class DopamineRecoveryService {
  const DopamineRecoveryService();

  List<String> microActions(EmotionalContext context) {
    final actions = <String>[
      'Drink a glass of water',
      'Write one sentence in your journal',
      'Take 10 mindful breaths',
    ];
    if (context.fatigue > 0.6) {
      actions.add('Stretch for 60 seconds');
    } else {
      actions.add('Take a 2-minute walk');
    }
    if (context.emotionalStability > 0.7) {
      actions.add('Mark one healthy win for today');
    }
    return actions;
  }
}
