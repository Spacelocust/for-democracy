import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/forms/group_form.dart';
import 'package:mobile/widgets/layout/error_message.dart';

class GroupEditScreen extends StatefulWidget {
  static const String routePath = 'edit/:groupId';

  static const String routeName = 'groupEdit';

  final int groupId;

  const GroupEditScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  Future<Group>? _groupFuture;

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  void fetchPlanets() {
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

          // Error state
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorMessage(
              onPressed: fetchPlanets,
              errorMessage: AppLocalizations.of(context)!.formLoadingFailed,
            );
          }

          // Success state
          final group = snapshot.data!;

          return ListView(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsEditScreenTitle,
                  style: TextStyleArame(
                    fontSize:
                        Theme.of(context).textTheme.headlineMedium!.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GroupForm(
                editing: true,
                initialData: GroupDTO(
                  name: group.name,
                  description: group.description,
                  private: !group.public,
                  planet: group.planet,
                  difficulty: group.difficulty,
                  startAt: group.startAt,
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
                    await GroupsService.editGroup(widget.groupId, formData);

                    if (context.mounted) {
                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.groupUpdated,
                      );

                      context.go(
                        context.namedLocation(
                          GroupScreen.routeName,
                          pathParameters: {
                            'groupId': widget.groupId.toString(),
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
