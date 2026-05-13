import 'package:flutter/foundation.dart';

import '../models/crisis_mode.dart';
import '../models/emotional_context.dart';
import '../models/emotional_environment.dart';
import '../models/grounding_system.dart';
import '../models/guardian_mode.dart';
import '../services/breathing_engine.dart';
import '../services/intervention_service.dart';

class InterventionProvider extends ChangeNotifier {
  InterventionProvider({InterventionService? service})
      : _service = service ?? InterventionService() {
    _syncState();
  }

  final InterventionService _service;
  EmotionalContext _context = EmotionalContext.neutral;
  EmotionalEnvironment? _environment;
  CrisisMode _crisisMode = CrisisMode.inactive;
  GroundingSystem? _grounding;
  GuardianMode? _guardianMode;
  BreathingPattern? _breathing;
  List<String> _recommendations = const <String>[];
  List<String> _dopamineReplacements = const <String>[];

  EmotionalContext get context => _context;
  EmotionalEnvironment? get environment => _environment;
  CrisisMode get crisisMode => _crisisMode;
  GroundingSystem? get grounding => _grounding;
  GuardianMode? get guardianMode => _guardianMode;
  BreathingPattern? get breathing => _breathing;
  List<String> get recommendations => _recommendations;
  List<String> get dopamineReplacements => _dopamineReplacements;

  void updateContext(EmotionalContext value) {
    _context = value;
    _syncState();
    notifyListeners();
  }

  void _syncState() {
    _environment = _service.buildEnvironment(_context);
    _crisisMode = _service.evaluateCrisisMode(_context);
    _grounding = _service.buildGroundingPlan(_context);
    _guardianMode = _service.buildGuardianMode(_context);
    _breathing = _service.breathingPattern(_context);
    _recommendations = _service.recommendedInterventions(_context);
    _dopamineReplacements = _service.dopamineReplacementSuggestions(_context);
  }
}
