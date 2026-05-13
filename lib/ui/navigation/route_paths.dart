/// Central route path constants — modules add subtrees via composition (TODO), not hardcoded here.
abstract final class RoutePaths {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const shell = '/';

  // Shell tabs
  static const dashboard = '/dashboard';
  static const insights = '/insights';
  static const journal = '/journal';
  static const companion = '/companion';
  static const progress = '/progress';

  /// Bottom-nav order — keep aligned with [StatefulShellRoute] branches.
  static const List<String> shellTabPaths = <String>[
    dashboard,
    insights,
    journal,
    companion,
    progress,
  ];

  // Top-level routes shown above the shell
  static const crisis = '/crisis';
  static const settings = '/settings';
}

