import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/providers/auth_dependency_providers.dart';
import '../../shared/providers/theme_mode_provider.dart';
import '../navigation/route_paths.dart';
import '../widgets/page_edge_navigation.dart';

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final idx = navigationShell.currentIndex;
    final lastTab = RoutePaths.shellTabPaths.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Crisis support',
            onPressed: () => context.push(RoutePaths.crisis),
            icon: const Icon(Icons.sos_rounded),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push(RoutePaths.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          navigationShell,
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: EdgeNavButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed:
                          idx > 0 ? () => navigationShell.goBranch(idx - 1) : null,
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: EdgeNavButton(
                      icon: Icons.chevron_right_rounded,
                      onPressed: idx < lastTab
                          ? () => navigationShell.goBranch(idx + 1)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.65),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Companion',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch_rounded),
            label: 'Progress',
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ListTile(
                title: const Text('Sign out'),
                leading: const Icon(Icons.logout_rounded),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Crisis support'),
                leading: const Icon(Icons.sos_rounded),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(RoutePaths.crisis);
                },
              ),
              ListTile(
                title: const Text('Settings'),
                leading: const Icon(Icons.settings_outlined),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(RoutePaths.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

