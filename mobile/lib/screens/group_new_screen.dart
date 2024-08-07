import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/screens/groups_screen.dart';
import 'package:mobile/services/groups_service.dart';
import 'package:mobile/services/planets_service.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/widgets/components/spinner.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/forms/group_form.dart';
import 'package:mobile/widgets/layout/error_message.dart';

class GroupNewScreen extends StatefulWidget {
  static const String routePath = 'new';

  static const String routeName = 'groupNew';

  final int? initialPlanetId;

  const GroupNewScreen({
    super.key,
    this.initialPlanetId,
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
      _planetsFuture = PlanetsService.getPlanets(
        onlyEvents: true,
      );
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
          final planets = snapshot.data!;

          return ListView(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.groupsNewScreenTitle,
                  style: TextStyleArame(
                    fontSize:
                        Theme.of(context).textTheme.headlineMedium!.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GroupForm(
                planets: planets,
                initialData: GroupDTO(
                  name: '',
                  description: null,
                  difficulty: Difficulty.trivial,
                  private: false,
                  startAt: DateTime.now(),
                  planet: widget.initialPlanetId != null
                      ? planets.firstWhere(
                          (planet) => planet.id == widget.initialPlanetId,
                        )
                      : null,
                ),
                onBackPress: () {
                  context.go(
                    context.namedLocation(GroupsScreen.routeName),
                  );
                },
                onSubmit: (formData) async {
                  try {
                    final newGroup = await GroupsService.createGroup(formData);

                    if (context.mounted) {
                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.groupCreated,
                      );

                      context.go(
                        context.namedLocation(
                          GroupScreen.routeName,
                          pathParameters: {
                            'groupId': newGroup.id.toString(),
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
