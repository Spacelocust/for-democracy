import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/group_new_screen.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/group/join_code_dialog.dart';
import 'package:mobile/widgets/layout/main_bottom_navigation_bar.dart';
import 'package:mobile/widgets/layout/main_navigation_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;

  const MainScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final GoRouterState routerState = GoRouterState.of(context);
    final user = context.watch<AuthState>().user;

    Widget? floatingActionButton;

    if (user != null) {
      if (routerState.matchedLocation == "/groups") {
        floatingActionButton = Padding(
          padding: const EdgeInsets.only(top: 90.0),
          child: SpeedDial(
            direction: SpeedDialDirection.down,
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: ThemeColors.primary,
            foregroundColor: ThemeColors.surface,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.groups),
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.surface,
                label: AppLocalizations.of(context)!.createGroup,
                onTap: () {
                  context.go(
                    context.namedLocation(
                      GroupNewScreen.routeName,
                    ),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.group_add),
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.surface,
                label: AppLocalizations.of(context)!.groupJoinCode,
                onTap: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const JoinCodeDialog();
                    },
                  );
                },
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Image(
              image: AssetImage("assets/images/helldivers-logo.png"),
              width: 25,
              height: 25,
            ),
            SizedBox(width: 10.0),
            Text(
              'For Democracy',
              style: TextStyleArame(),
            )
          ],
        ),
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
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
