import 'package:flutter/material.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/widgets/components/square_avatar.dart';
import 'package:mobile/widgets/layout/main_bottom_navigation_bar.dart';
import 'package:mobile/widgets/layout/main_navigation_drawer.dart';
import 'package:mobile/widgets/layout/user_navigation_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For Democracy'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return const UserProfileButton();
            },
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigationBar(),
      drawer: const MainNavigationDrawer(),
      endDrawer: const UserNavigationDrawer(),
      body: body,
    );
  }
}

class UserProfileButton extends StatelessWidget {
  const UserProfileButton({super.key});

  @override
  FutureBuilder<User?> build(BuildContext context) {
    return FutureBuilder<User?>(
      future: context.watch<AuthState>().getUser(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          case ConnectionState.done:
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: SquareAvatar(
                  avatar: Image.network(snapshot.data!.avatarUrl),
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                ),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: AppLocalizations.of(context)!.userDrawerTooltip,
              );
            }
          default:
            return IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: AppLocalizations.of(context)!.userDrawerTooltip,
            );
        }
      },
    );
  }
}
