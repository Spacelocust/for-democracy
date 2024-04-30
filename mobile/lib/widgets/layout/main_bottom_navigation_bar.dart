import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  State<MainBottomNavigationBar> createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  final Map<String, int> routeIndexMapping = {
    '/planets': 0,
    '/events': 1,
    '/groups': 2,
  };

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    GoRouterState routerState = GoRouterState.of(context);

    return NavigationBar(
      onDestinationSelected: (int index) {
        String route = routeIndexMapping.keys.firstWhere(
          (key) => routeIndexMapping[key] == index,
          orElse: () => routeIndexMapping.keys.first,
        );

        context.go(route);
      },
      indicatorColor: ThemeColors.primary,
      selectedIndex: routeIndexMapping[routerState.matchedLocation] ??
          routeIndexMapping.values.first,
      destinations: <Widget>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.planets,
        ),
        NavigationDestination(
          icon: const Icon(Icons.event_outlined),
          selectedIcon: const Icon(Icons.event),
          label: AppLocalizations.of(context)!.events,
        ),
        NavigationDestination(
          icon: const Icon(Icons.group_outlined),
          selectedIcon: const Icon(Icons.group),
          label: AppLocalizations.of(context)!.groups,
        ),
      ],
    );
  }
}
