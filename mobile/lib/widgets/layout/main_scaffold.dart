import 'package:flutter/material.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/widgets/layout/main_bottom_navigation_bar.dart';
import 'package:mobile/widgets/layout/main_navigation_drawer.dart';
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
      body: body,
    );
  }
}

class UserProfileButton extends StatelessWidget {
  const UserProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;

    if (user != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: Icon(Icons.account_circle),
    );
  }
}
