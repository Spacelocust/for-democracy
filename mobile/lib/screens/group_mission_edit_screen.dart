import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/dto/mission_dto.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/models/mission.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/services/missions_service.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/forms/group_mission_form.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupMissionEditScreen extends StatefulWidget {
  static const String routePath = 'mission/edit/:missionId';

  static const String routeName = 'missionEdit';

  final int groupId;

  final int missionId;

  const GroupMissionEditScreen({
    super.key,
    required this.groupId,
    required this.missionId,
  });

  @override
  State<GroupMissionEditScreen> createState() => _GroupMissionEditScreenState();
}

class _GroupMissionEditScreenState extends State<GroupMissionEditScreen> {
  Future<dynamic>? _missionAndGroupFuture;

  @override
  void initState() {
    super.initState();
    fetchMissionAndGroup();
  }

  void fetchMissionAndGroup() {
    setState(() {
      _missionAndGroupFuture = Future.wait([
        MissionsService.getMission(widget.missionId),
        GroupsService.getGroup(widget.groupId),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<dynamic>(
        future: _missionAndGroupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Spinner(
              semanticsLabel: AppLocalizations.of(context)!.formLoading,
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            // Error state
            return ErrorMessage(
              errorMessage: AppLocalizations.of(context)!.formLoadingFailed,
              onPressed: fetchMissionAndGroup,
            );
          }

          // Success state
          final Mission mission = snapshot.data![0];
          final Group group = snapshot.data![1];

          return ListView(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsMissionEditScreenTitle,
                  style: TextStyleArame(
                    fontSize:
                        Theme.of(context).textTheme.headlineMedium!.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GroupMissionForm(
                group: group,
                initialData: MissionDTO(
                  name: mission.name,
                  instructions: mission.instructions,
                  objectives: mission.objectiveTypes,
                ),
                onBackPress: () {
                  context.go(
                    context.namedLocation(
                      GroupScreen.routeName,
                      pathParameters: {
                        'groupId': group.id.toString(),
                      },
                    ),
                  );
                },
                onSubmit: (formData) async {
                  try {
                    await MissionsService.editMission(
                      group.id,
                      mission.id,
                      formData,
                    );

                    if (context.mounted) {
                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.missionUpdated,
                      );

                      context.go(
                        context.namedLocation(
                          GroupScreen.routeName,
                          pathParameters: {
                            'groupId': group.id.toString(),
                          },
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    var statusCode = e.response?.statusCode;

                    if (!context.mounted || statusCode == null) {
                      return;
                    }

                    if (statusCode < 500) {
                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.invalidForm,
                      );
                    } else {
                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.somethingWentWrong,
                      );
                    }
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }

                    showSnackBar(
                      context,
                      AppLocalizations.of(context)!.somethingWentWrong,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
