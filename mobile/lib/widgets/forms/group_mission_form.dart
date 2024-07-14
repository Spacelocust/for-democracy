import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:mobile/dto/mission_dto.dart';
import 'package:mobile/enum/objective_type.dart';
import 'package:mobile/models/group.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';

class GroupMissionForm extends StatefulWidget {
  /// The group that the mission will be created for.
  final Group group;

  /// The function to call when the back button is pressed.
  final Function()? onBackPress;

  /// The function to call when the form is submitted.
  final Future<void> Function(MissionDTO formData)? onSubmit;

  /// The initial data to populate the form with.
  final MissionDTO? initialData;

  const GroupMissionForm({
    required this.group,
    this.onBackPress,
    this.onSubmit,
    this.initialData,
    super.key,
  });

  @override
  GroupMissionFormState createState() {
    return GroupMissionFormState();
  }
}

class GroupMissionFormState extends State<GroupMissionForm> {
  final _formKey = GlobalKey<FormState>();

  late final MissionDTO _formData;

  var _submitting = false;

  @override
  void initState() {
    super.initState();

    _formData = MissionDTO(
      name: widget.initialData?.name ?? '',
      instructions: widget.initialData?.instructions ?? '',
      objectives: widget.initialData?.objectives ?? [],
    );
  }

  void onBackPress() {
    if (widget.onBackPress != null) {
      widget.onBackPress!();
    }
  }

  void onSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_formData.objectives.isEmpty) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.missionObjectivesNotEmpty,
        );

        return;
      }

      if (widget.onSubmit == null) {
        return;
      }

      setState(() {
        _submitting = true;
      });

      try {
        await widget.onSubmit!(_formData);
      } finally {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  List<Widget> _buildObjectives() {
    final objectives = ObjectiveType.getavailableForFactionAndDifficulty(
      widget.group.planet.owner,
      widget.group.difficulty,
    );
    final objectiveTiles = <Widget>[];

    for (final objective in objectives) {
      objectiveTiles.add(
        CheckboxListTile(
          value: _formData.objectives.contains(objective),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _formData.objectives.add(objective);
              } else {
                _formData.objectives.remove(objective);
              }
            });
          },
          secondary: Image(
            image: AssetImage(objective.logo),
            width: 30,
            height: 30,
          ),
          title: Text(objective.translatedName(context)),
          subtitle: Text(
            AppLocalizations.of(context)!.missionObjectiveTimeLimit(
              prettyDuration(
                objective.duration,
                locale: DurationLocale.fromLanguageCode(
                  Localizations.localeOf(context).languageCode,
                )!,
              ),
            ),
          ),
        ),
      );
    }

    return objectiveTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // Name
          TextFormField(
            initialValue: _formData.name,
            enabled: !_submitting,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.missionName,
              hintText: AppLocalizations.of(context)!.missionNameHint,
            ),
            validator: (value) {
              final trimmedValue = value?.trim();

              if (trimmedValue == null || trimmedValue.isEmpty) {
                return AppLocalizations.of(context)!.missionNameNotEmpty;
              }

              if (trimmedValue.length > 50) {
                return AppLocalizations.of(context)!.missionNameMaxLength;
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _formData.name = value;
              });
            },
          ),
          const SizedBox(height: 2),
          // Instructions
          TextFormField(
            initialValue: _formData.instructions,
            enabled: !_submitting,
            minLines: 3,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.missionInstructions,
              hintText: AppLocalizations.of(context)!.missionInstructionsHint,
            ),
            validator: (value) {
              final trimmedValue = value?.trim();

              if (trimmedValue == null) {
                return null;
              }

              if (trimmedValue.length > 1000) {
                return AppLocalizations.of(context)!
                    .missionInstructionsMaxLength;
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _formData.instructions = value;
              });
            },
          ),
          const SizedBox(height: 18),
          // Objectives
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.missionObjectives,
              style: const TextStyleArame(),
            ),
          ),
          ..._buildObjectives(),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context)!.back),
                onPressed: _submitting ? null : onBackPress,
              ),
              OutlinedButton.icon(
                onPressed: _submitting ? null : onSubmit,
                icon: const Icon(Icons.save),
                label: Text(
                  AppLocalizations.of(context)!.save,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
