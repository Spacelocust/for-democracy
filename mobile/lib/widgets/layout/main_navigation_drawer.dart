import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/drawer_destination.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/screens/events_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/screens/planets_screen.dart';
import 'package:mobile/screens/web_oauth_screen.dart';
import 'package:mobile/services/secure_storage_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/widgets/components/square_avatar.dart';
import 'package:provider/provider.dart';

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
    final User? user = context.watch<AuthState>().user;

    return NavigationDrawer(
      onDestinationSelected: (int index) {
        context.go(destinations[index].path);
      },
      selectedIndex: destinations.indexWhere(
        (DrawerDestination drawerDestination) =>
            routerState.matchedLocation.startsWith(drawerDestination.path),
      ),
      children: <Widget>[
        DrawerItem(
          child: Text(
            AppLocalizations.of(context)!.mainDrawerTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...destinations.map(
          (DrawerDestination drawerDestination) =>
              drawerDestination.destination,
        ),
        const DrawerItem(
          child: Divider(),
        ),
        if (user != null)
          DrawerItem(
            child: UserProfile(user: user),
          ),
        const DrawerItem(
          child: AuthButton(),
        ),
      ],
    );
  }
}

class DrawerItem extends StatelessWidget {
  final Widget child;
  const DrawerItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
      child: child,
    );
  }
}

/// Display the user's profile information.
class UserProfile extends StatelessWidget {
  final User user;

  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SquareAvatar(
          size: 45,
          avatar: Image.network(user.avatarUrl),
        ),
        const SizedBox(width: 16),
        Text(
          user.username,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

/// Display the authentication button.
class AuthButton extends StatelessWidget {
  const AuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    void openSteamModal() {
      const double modalSize = 0.95;

      showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: modalSize,
          maxChildSize: modalSize,
          expand: false,
          builder: (context, scrollController) => SafeArea(
            child: SingleChildScrollView(
              controller: scrollController,
              child: const WebOAuthScreen(),
            ),
          ),
        ),
      );
    }

    if (context.watch<AuthState>().user != null) {
      return OutlinedButton(
        onPressed: () {
          context.read<AuthState>().setUser(null);
          SecureStorageService().deleteSecureData("token");

          context.pop();
        },
        child: Text(
          AppLocalizations.of(context)!.logout,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: openSteamModal,
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Image(
          image: AssetImage('assets/steam-logo.png'),
          height: 30,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
