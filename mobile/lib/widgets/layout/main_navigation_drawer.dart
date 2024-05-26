import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/drawer_destination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/screens/events_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/screens/planets_screen.dart';

class MainNavigationDrawer extends StatelessWidget {
  const MainNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouterState routerState = GoRouterState.of(context);
    final List<DrawerDestination> destinations = [
      DrawerDestination(
        path: PlanetsScreen.routePath,
        destination: NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(AppLocalizations.of(context)!.planets),
        ),
      ),
      DrawerDestination(
        path: EventsScreen.routePath,
        destination: NavigationDrawerDestination(
          icon: const Icon(Icons.event_outlined),
          selectedIcon: const Icon(Icons.event),
          label: Text(AppLocalizations.of(context)!.events),
        ),
      ),
      DrawerDestination(
        path: GroupsScreen.routePath,
        destination: NavigationDrawerDestination(
          icon: const Icon(Icons.group_outlined),
          selectedIcon: const Icon(Icons.group),
          label: Text(AppLocalizations.of(context)!.groups),
        ),
      ),
    ];

    return NavigationDrawer(
      onDestinationSelected: (int index) {
        context.go(destinations[index].path);
      },
      selectedIndex: destinations.indexWhere(
        (DrawerDestination drawerDestination) =>
            drawerDestination.path == routerState.matchedLocation,
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            AppLocalizations.of(context)!.mainDrawerTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...destinations.map(
          (DrawerDestination drawerDestination) =>
              drawerDestination.destination,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
      ],
    );
  }
}
