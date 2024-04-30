import 'package:flutter/material.dart';
import 'package:mobile/widgets/layout/main_bottom_navigation_bar.dart';
import 'package:mobile/widgets/layout/main_navigation_drawer.dart';
import 'package:mobile/widgets/layout/user_navigation_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: AppLocalizations.of(context)!.userDrawerTooltip,
              );
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
