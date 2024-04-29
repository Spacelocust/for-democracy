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
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    GoRouterState routerState = GoRouterState.of(context);
    Map<String, int> routeIndexMapping = {
      '/planets': 0,
      '/events': 1,
      '/groups': 2,
    };

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
          selectedIcon: const Icon(Icons.home),
          icon: const Icon(Icons.home_outlined),
          label: AppLocalizations.of(context)!.planets,
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.event),
          icon: const Icon(Icons.event_outlined),
          label: AppLocalizations.of(context)!.events,
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.group),
          icon: const Icon(Icons.group_outlined),
          label: AppLocalizations.of(context)!.groups,
        ),
      ],
    );
  }
}
