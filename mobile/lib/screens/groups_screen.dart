import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/layout/error_message.dart';

class GroupsScreen extends StatefulWidget {
  static const String routePath = '/groups';

  static const String routeName = 'groups';

  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  Future<List<Group>>? _groupsFuture;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  void fetchGroups() {
    setState(() {
      _groupsFuture = GroupsService.getGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Spinner(
              semanticsLabel: AppLocalizations.of(context)!.eventsScreenLoading,
            );
          }

          // Error state
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorMessage(
              onPressed: fetchGroups,
              errorMessage: AppLocalizations.of(context)!.eventsScreenError,
            );
          }

          // Success state
          final groups = snapshot.data!;

          return ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: Column(children: [
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.eventsOngoingDefences,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...groups.map(
                    (group) => ListTile(
                      onTap: () {
                        context.go(
                          context.namedLocation(
                            GroupScreen.routeName,
                            pathParameters: {'groupId': group.id.toString()},
                          ),
                        );
                      },
                      title: Text(group.name),
                    ),
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
