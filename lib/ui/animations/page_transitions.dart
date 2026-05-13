import 'package:flutter/material.dart';

/// Reserved for shared page transition utilities.
///
/// NOTE: The app currently relies on theme-level transitions (`AppTheme`).
/// Future teams can add custom transition builders here and wire them through
/// `go_router` page builders without touching module internals.
abstract final class PageTransitions {
  static const Duration defaultDuration = Duration(milliseconds: 280);
  static const Curve defaultCurve = Curves.easeOutCubic;
}

