import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/states/groups_filters_state.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:provider/provider.dart';

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
              semanticsLabel: AppLocalizations.of(context)!.groupsScreenLoading,
            );
          }

          // Error state
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorMessage(
              onPressed: fetchGroups,
              errorMessage: AppLocalizations.of(context)!.groupsScreenError,
            );
          }

          // Success state
          final currentUser = context.read<AuthState>().user;
          final initialGroups = snapshot.data!;
          final allPlanets = AppLocalizations.of(context)!.groupsAllPlanets;
          final List<String> planetFilters = <String>[
            allPlanets,
            ...initialGroups.fold<List<String>>(
              <String>[],
              (List<String> currentList, group) {
                final groupPlanet = group.planet.name;

                if (currentList.contains(groupPlanet)) {
                  return currentList;
                }

                currentList.add(groupPlanet);

                return currentList;
              },
            ),
          ];
          final groups = initialGroups.where((group) {
            if (context.read<GroupsFiltersState>().myGroups &&
                group.owner?.user != currentUser) {
              return false;
            }

            if (context.read<GroupsFiltersState>().planet != null &&
                context.read<GroupsFiltersState>().planet != allPlanets &&
                group.planet.name !=
                    context.read<GroupsFiltersState>().planet) {
              return false;
            }

            return true;
          }).toList();

          final List<Widget> groupsList = [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.groupsAllGroups,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Divider(
                height: 10,
                thickness: 2,
                color: ThemeColors.primary,
              ),
            ),
            DropdownMenu<String>(
              label: Text(AppLocalizations.of(context)!.planet),
              expandedInsets: EdgeInsets.zero,
              initialSelection: planetFilters.first,
              onSelected: (String? value) {
                setState(() {
                  context.read<GroupsFiltersState>().setPlanet(value);
                });
              },
              dropdownMenuEntries:
                  planetFilters.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            const SizedBox(
              height: 20,
            ),
            SwitchListTile(
              value: context.read<GroupsFiltersState>().myGroups,
              activeColor: ThemeColors.primary,
              title: Text(AppLocalizations.of(context)!.groupsOnlyMyGroups),
              onChanged: (bool value) {
                setState(() {
                  context.read<GroupsFiltersState>().setMyGroups(value);
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Divider(
                height: 10,
                thickness: 2,
                color: ThemeColors.primary,
              ),
            ),
            ...groups.map(
              (group) => ListTile(
                onTap: () {
                  context.go(
                    context.namedLocation(
                      GroupScreen.routeName,
                      pathParameters: {
                        'groupId': group.id.toString(),
                      },
                    ),
                  );
                },
                title: Text(group.name),
              ),
            ),
            if (groups.isEmpty)
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsNoGroups,
                  textAlign: TextAlign.center,
                ),
              ),
          ];

          return ListView.builder(
            itemCount: groupsList.length,
            itemBuilder: (context, index) {
              return groupsList[index];
            },
          );
        },
      ),
    );
  }
}
