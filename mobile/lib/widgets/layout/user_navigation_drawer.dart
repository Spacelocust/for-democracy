import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/drawer_destination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserNavigationDrawer extends StatelessWidget {
  const UserNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouterState routerState = GoRouterState.of(context);
    final List<DrawerDestination> destinations = [];

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
            AppLocalizations.of(context)!.userDrawerTitle,
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
