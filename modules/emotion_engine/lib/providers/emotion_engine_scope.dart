import 'package:flutter/widgets.dart';

import '../services/emotion_service.dart';

/// Lightweight DI scope so screens stay decoupled from global app providers.
class EmotionEngineScope extends InheritedWidget {
  const EmotionEngineScope({
    super.key,
    required this.service,
    required super.child,
  });

  final EmotionService service;

  static EmotionService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EmotionEngineScope>();
    assert(scope != null, 'EmotionEngineScope not found — wrap module screens.');
    return scope!.service;
  }

  @override
  bool updateShouldNotify(covariant EmotionEngineScope oldWidget) {
    return oldWidget.service != service;
  }
}
