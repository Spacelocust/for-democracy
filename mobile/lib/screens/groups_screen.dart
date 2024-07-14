import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/group_new_screen.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/states/groups_filters_state.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/helldivers_list_item.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/group/join_code_dialog.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  static const String routePath = '/groups';

  static const String routeName = 'groups';

  const GroupsScreen({
    super.key,
  });

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
          final List<Planet> planetFilters = initialGroups.fold<List<Planet>>(
            <Planet>[],
            (List<Planet> currentList, group) {
              final groupPlanet = group.planet;

              if (currentList.any((planet) => planet.id == groupPlanet.id)) {
                return currentList;
              }

              currentList.add(groupPlanet);

              return currentList;
            },
          );
          final groups = initialGroups.where((group) {
            // My groups
            if (context.read<GroupsFiltersState>().myGroups) {
              if (currentUser == null) {
                return false;
              }

              if (!group.isMember(currentUser.steamId)) {
                return false;
              }
            }

            final planetFilter = context.read<GroupsFiltersState>().planet;

            // Planet
            if (planetFilter != null &&
                planetFilters.any((planet) => planet.id == planetFilter)) {
              if (group.planet.id != planetFilter) {
                return false;
              }
            }

            final difficultyFilter =
                context.read<GroupsFiltersState>().difficulty;

            // Difficulty
            if (difficultyFilter != null) {
              if (group.difficulty != difficultyFilter) {
                return false;
              }
            }

            return true;
          }).toList();

          final List<Widget> groupsList = [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.groups,
                style: TextStyleArame(
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize,
                ),
              ),
              trailing: SpeedDial(
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
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.filters,
                style: const TextStyleArame(),
              ),
            ),
            // Planet filter
            DropdownMenu<int?>(
              label: Text(AppLocalizations.of(context)!.planet),
              expandedInsets: EdgeInsets.zero,
              initialSelection: null,
              onSelected: (int? value) {
                setState(() {
                  context.read<GroupsFiltersState>().setPlanet(value);
                });
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: null,
                  label: AppLocalizations.of(context)!.groupsAllPlanets,
                ),
                ...planetFilters.map<DropdownMenuEntry<int?>>((Planet planet) {
                  return DropdownMenuEntry<int?>(
                    value: planet.id,
                    label: planet.name,
                  );
                }),
              ],
            ),
            // Difficulty filter
            DropdownMenu<Difficulty?>(
              label: Text(AppLocalizations.of(context)!.difficulty),
              expandedInsets: EdgeInsets.zero,
              initialSelection: null,
              onSelected: (Difficulty? value) {
                setState(() {
                  context.read<GroupsFiltersState>().setDifficulty(value);
                });
              },
              dropdownMenuEntries: [
                DropdownMenuEntry<Difficulty?>(
                  value: null,
                  label: AppLocalizations.of(context)!.groupsAllDifficulties,
                ),
                ...Difficulty.values.map<DropdownMenuEntry<Difficulty>>(
                    (Difficulty difficulty) {
                  return DropdownMenuEntry<Difficulty>(
                    value: difficulty,
                    label: difficulty.translatedName(context),
                    leadingIcon: Image(
                      image: AssetImage(difficulty.logo),
                      width: 30,
                      height: 30,
                    ),
                  );
                }),
              ],
            ),
            // My groups filter
            if (currentUser != null)
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
            ListTile(
              title: Text(
                "${AppLocalizations.of(context)!.results} (${groups.length})",
                style: const TextStyleArame(),
              ),
            ),
            ...groups.map(
              (group) {
                return HelldiversListTile(
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (!group.public)
                        const Icon(
                          Icons.lock,
                          size: 16,
                        ),
                      if (!group.public) const SizedBox(width: 5),
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  subtitle: Wrap(children: [
                    Text(group.planet.name),
                  ]),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${DateFormat.MMMMd().format(group.startAt)}, ${DateFormat.Hm().format(group.startAt)}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        "${group.groupUsers.length.toString()}/4",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  leading: Image(
                    image: AssetImage(group.difficulty.logo),
                    width: 30,
                    height: 30,
                  ),
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
                );
              },
            ),
            if (groups.isEmpty)
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsNoGroups,
                  textAlign: TextAlign.center,
                ),
              ),
          ];

          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 16),
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
