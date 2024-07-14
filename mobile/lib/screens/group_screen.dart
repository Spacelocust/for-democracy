import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/screens/group_edit_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/states/auth_state.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/confirm_action_dialog.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/widgets/planet/list_item.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class GroupScreen extends StatefulWidget {
  static const String routePath = ':groupId';

  static const String routeName = 'group';

  final int groupId;

  const GroupScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Future<Group>? _groupFuture;

  @override
  void initState() {
    super.initState();
    fetchGroup();
  }

  void fetchGroup() {
    setState(() {
      _groupFuture = GroupsService.getGroup(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Group>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Spinner(
              semanticsLabel: AppLocalizations.of(context)!.groupScreenLoading,
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            // Error state
            return ErrorMessage(
              errorMessage: AppLocalizations.of(context)!.groupScreenError,
              onPressed: fetchGroup,
            );
          }

          // Success state
          final user = context.watch<AuthState>().user;
          final group = snapshot.data!;
          final groupUsers = group.groupUsers;
          Widget? actions;

          groupUsers.sort((a, b) {
            if (a.owner) {
              return -1;
            }

            return 1;
          });

          if (user != null) {
            actions = SpeedDial(
              direction: SpeedDialDirection.up,
              icon: Icons.more_vert,
              activeIcon: Icons.close,
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.surface,
              children: [
                if (group.isOwner(user.steamId))
                  SpeedDialChild(
                    child: const Icon(Icons.delete),
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: ThemeColors.surface,
                    label: AppLocalizations.of(context)!.delete,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ConfirmActionDialog(
                            onConfirm: () async {
                              try {
                                await GroupsService.deleteGroup(group.id);

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .groupDeleted,
                                    ),
                                  ),
                                );

                                GoRouter.of(context).go(
                                  context.namedLocation(
                                    GroupsScreen.routeName,
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .somethingWentWrong,
                                    ),
                                  ),
                                );
                              } finally {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                if (group.isOwner(user.steamId))
                  SpeedDialChild(
                    child: const Icon(Icons.edit),
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: ThemeColors.surface,
                    label: AppLocalizations.of(context)!.edit,
                    onTap: () {
                      context.go(
                        context.namedLocation(
                          GroupEditScreen.routeName,
                          pathParameters: {
                            'groupId': group.id.toString(),
                          },
                        ),
                      );
                    },
                  ),
                if (!group.isOwner(user.steamId) &&
                    group.isMember(user.steamId))
                  SpeedDialChild(
                    child: const Icon(Icons.exit_to_app),
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: ThemeColors.surface,
                    label: AppLocalizations.of(context)!.leave,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ConfirmActionDialog(
                            actionText: AppLocalizations.of(context)!.leave,
                            content: Text(
                              AppLocalizations.of(context)!
                                  .groupLeaveConfirmation,
                            ),
                            onConfirm: () async {
                              try {
                                await GroupsService.leaveGroup(group.id);

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!.groupLeft,
                                    ),
                                  ),
                                );

                                context.go(
                                  context.namedLocation(
                                    GroupScreen.routeName,
                                    pathParameters: {
                                      'groupId': group.id.toString(),
                                    },
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .somethingWentWrong,
                                    ),
                                  ),
                                );
                              } finally {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                if (!group.isOwner(user.steamId) &&
                    !group.isMember(user.steamId))
                  SpeedDialChild(
                    child: const Icon(Icons.add),
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: ThemeColors.surface,
                    label: AppLocalizations.of(context)!.join,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return ConfirmActionDialog(
                            actionText: AppLocalizations.of(context)!.join,
                            content: Text(
                              AppLocalizations.of(context)!
                                  .groupJoinConfirmation,
                            ),
                            onConfirm: () async {
                              try {
                                await GroupsService.joinGroup(group.id);

                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!.groupJoined,
                                    ),
                                  ),
                                );

                                context.go(
                                  context.namedLocation(
                                    GroupScreen.routeName,
                                    pathParameters: {
                                      'groupId': group.id.toString(),
                                    },
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .somethingWentWrong,
                                    ),
                                  ),
                                );
                              } finally {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          }

          return ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    group.name,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyleArame(
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium!.fontSize,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage(group.difficulty.logo),
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 8),
                      GradientText(
                        group.difficulty.translatedName(context),
                        textAlign: TextAlign.center,
                        style: TextStyleArame(
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .fontSize,
                        ),
                        colors: group.difficulty.gradient,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        group.code!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          semanticLabel: AppLocalizations.of(context)!.copy,
                        ),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: group.code!),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "${DateFormat.MMMMd().format(group.startAt)}, ${DateFormat.Hm().format(group.startAt)}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
              const SizedBox(height: 16),
              if (group.description != null)
                Text(
                  group.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.planet,
                  style: const TextStyleArame(),
                ),
              ),
              PlanetListItem(
                planet: group.planet,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  "${AppLocalizations.of(context)!.members} (${groupUsers.length}/4)",
                  style: const TextStyleArame(),
                ),
              ),
              ...groupUsers.map(
                (groupUser) => _GroupMember(
                  name: groupUser.user!.username,
                  avatar: groupUser.user!.avatarUrl,
                  owner: groupUser.owner,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  "${AppLocalizations.of(context)!.missions} (${group.missions.length})",
                  style: const TextStyleArame(),
                ),
              ),
              if (group.missions.isEmpty)
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.noMissions,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              // TODO missions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppLocalizations.of(context)!.back),
                    onPressed: () {
                      context.go(context.namedLocation(GroupsScreen.routeName));
                    },
                  ),
                  if (actions != null) actions,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupMember extends StatelessWidget {
  final String name;

  final String avatar;

  final bool owner;

  const _GroupMember({
    required this.name,
    required this.avatar,
    this.owner = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: avatar,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          width: 40,
          height: 40,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: ThemeColors.primary,
            child: Container(
              decoration: const BoxDecoration(
                color: ThemeColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: owner
          ? const Icon(
              Icons.star,
              color: ThemeColors.primary,
            )
          : null,
    );
  }
}
