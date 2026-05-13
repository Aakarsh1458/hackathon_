import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EmotionalState {
  calm,
  elevated,
  overloaded,
  recovering,
}

class AppStateNotifier extends ChangeNotifier {
  EmotionalState _emotionalState = EmotionalState.calm;
  double _stressScore = 0.35;
  bool _chatbotActive = false;
  String _companionState = 'idle';
  String _interventionState = 'adaptive';
  double _recoveryProgress = 0.0;
  int _streakDays = 0;

  EmotionalState get emotionalState => _emotionalState;
  double get stressScore => _stressScore;
  bool get chatbotActive => _chatbotActive;
  String get companionState => _companionState;
  String get interventionState => _interventionState;
  double get recoveryProgress => _recoveryProgress;
  int get streakDays => _streakDays;

  void updateEmotionalState(EmotionalState value) {
    _emotionalState = value;
    notifyListeners();
  }

  void updateStressScore(double value) {
    _stressScore = value.clamp(0, 1);
    notifyListeners();
  }

  void setChatbotActive(bool value) {
    _chatbotActive = value;
    notifyListeners();
  }

  void updateCompanionState(String value) {
    _companionState = value;
    notifyListeners();
  }

  void updateInterventionState(String value) {
    _interventionState = value;
    notifyListeners();
  }

  void updateRecoveryMetrics({
    double? recoveryProgress,
    int? streakDays,
  }) {
    _recoveryProgress = (recoveryProgress ?? _recoveryProgress).clamp(0, 1);
    _streakDays = streakDays ?? _streakDays;
    notifyListeners();
  }
}

final appStateProvider = ChangeNotifierProvider<AppStateNotifier>((ref) {
  return AppStateNotifier();
});
