import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/groups_service.dart';
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
              semanticsLabel: AppLocalizations.of(context)!.groupsScreenLoading,
            );
          }

          // Error state
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorMessage(
              onPressed: fetchPlanets,
              errorMessage: AppLocalizations.of(context)!.groupsScreenError,
            );
          }

          // Success state
          final group = snapshot.data!;

          return Column(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsAllGroups,
                  style: const TextStyleArame(),
                ),
              ),
              GroupForm(
                editing: true,
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
                  } on DioException catch (e) {
                    var statusCode = e.response?.statusCode;

                    if (!context.mounted || statusCode == null) {
                      return;
                    }

                    if (statusCode < 500) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                                Text(AppLocalizations.of(context)!.invalidForm),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                    } else {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .somethingWentWrong),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                    }
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.somethingWentWrong,
                        ),
                        duration: const Duration(seconds: 5),
                      ),
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
