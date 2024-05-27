import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/drawer_destination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/screens/web_oauth_screen.dart';
import 'package:mobile/services/secure_storage_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:provider/provider.dart';

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
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 18, 10),
          child: UserProfile(),
        ),
        ...destinations.map(
          (DrawerDestination drawerDestination) =>
              drawerDestination.destination,
        ),
        const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10), child: AuthButton()),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
      ],
    );
  }
}

// UserProfile is a widget that displays the user's profile information.
class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: context.watch<AuthState>().getUser(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.network(snapshot.data!.avatarUrl, height: 45),
                ),
                const SizedBox(width: 16),
                Text(
                  snapshot.data!.username,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            );
          } else {
            return Text(
              AppLocalizations.of(context)!.userDrawerTitle,
              style: Theme.of(context).textTheme.titleSmall,
            );
          }
        } else {
          return Text(
            AppLocalizations.of(context)!.userDrawerTitle,
            style: Theme.of(context).textTheme.titleSmall,
          );
        }
      },
    );
  }
}

// AuthButton is a widget that displays a button that allows the user to log in or log out.
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
              child: const WebOauthScreen(),
            ),
          ),
        ),
      );
    }

    if (context.watch<AuthState>().token != null) {
      return MaterialButton(
          color: Colors.grey,
          onPressed: () {
            context.read<AuthState>().setToken(null);
            SecureStorageService().deleteSecureData("token");
          },
          child: Text(
            AppLocalizations.of(context)!.logout,
            style: Theme.of(context).textTheme.titleSmall,
          ));
    } else {
      return GestureDetector(
          onTap: openSteamModal,
          child: const Image(
            image: AssetImage('assets/steam-signin.png'),
            height: 60,
            alignment: Alignment.centerLeft,
          ));
    }
  }
}
