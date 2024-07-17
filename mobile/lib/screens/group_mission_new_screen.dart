import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/services/missions_service.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/forms/group_mission_form.dart';
import 'package:mobile/widgets/layout/error_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupMissionNewScreen extends StatefulWidget {
  static const String routePath = 'mission/new';

  static const String routeName = 'missionNew';

  final int groupId;

  const GroupMissionNewScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupMissionNewScreen> createState() => _GroupMissionNewScreenState();
}

class _GroupMissionNewScreenState extends State<GroupMissionNewScreen> {
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
              semanticsLabel: AppLocalizations.of(context)!.formLoading,
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            // Error state
            return ErrorMessage(
              errorMessage: AppLocalizations.of(context)!.formLoadingFailed,
              onPressed: fetchGroup,
            );
          }

          // Success state
          final group = snapshot.data!;

          return ListView(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsMissionNewScreenTitle,
                  style: TextStyleArame(
                    fontSize:
                        Theme.of(context).textTheme.headlineMedium!.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GroupMissionForm(
                group: group,
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
                    await MissionsService.createMission(
                      group.id,
                      formData,
                    );

                    if (context.mounted) {
                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.missionCreated,
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
