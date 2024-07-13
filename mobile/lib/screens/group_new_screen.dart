import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_arame.dart';
import 'package:mobile/widgets/forms/group_form.dart';
import 'package:mobile/widgets/layout/error_message.dart';

class GroupNewScreen extends StatefulWidget {
  static const String routePath = 'new';

  static const String routeName = 'groupNew';

  const GroupNewScreen({
    super.key,
  });

  @override
  State<GroupNewScreen> createState() => _GroupNewScreenState();
}

class _GroupNewScreenState extends State<GroupNewScreen> {
  Future<List<Planet>>? _planetsFuture;

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  void fetchPlanets() {
    setState(() {
      _planetsFuture = PlanetsService.getPlanets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<Planet>>(
        future: _planetsFuture,
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
          final planets = snapshot.data!;

          return Column(
            children: [
              ListTile(
                title: TextArame(
                  text: AppLocalizations.of(context)!.groupsAllGroups,
                ),
              ),
              GroupForm(
                planets: planets,
                onBackPress: () {
                  context.go(
                    context.namedLocation(GroupsScreen.routeName),
                  );
                },
                onSubmit: (formData) async {
                  try {
                    await GroupsService.createGroup(formData);
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
