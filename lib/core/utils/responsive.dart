import 'package:flutter/widgets.dart';

enum ScreenClass { compact, medium, expanded }

/// Mobile-first breakpoints — shell layout only.
ScreenClass screenClassOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 900) {
    return ScreenClass.expanded;
  }
  if (w >= 600) {
    return ScreenClass.medium;
  }
  return ScreenClass.compact;
}
