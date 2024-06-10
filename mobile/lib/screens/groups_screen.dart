import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/widgets/components/list_item.dart';

class GroupsScreen extends StatefulWidget {
  static const String routePath = '/groups';

  static const String routeName = 'groups';

  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
            ),
            child: Column(children: [
              // Defences
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsAllGroups,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go(context.namedLocation(
                    GroupScreen.routeName,
                  ));
                },
                child: const ListItem(
                  title: 'Group 1',
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}
