import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/models/planet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker_theme;
import 'package:mobile/utils/theme_colors.dart';

class GroupForm extends StatefulWidget {
  /// The list of planets to choose from.
  final List<Planet>? planets;

  /// The function to call when the back button is pressed.
  final Function()? onBackPress;

  /// The function to call when the form is submitted.
  final Future<void> Function(GroupDTO formData)? onSubmit;

  /// The initial data to populate the form with.
  final GroupDTO? initialData;

  /// Whether the form is in editing mode. This will remove the `planet` and `difficulty` fields.
  final bool editing;

  const GroupForm({
    this.planets,
    this.onBackPress,
    this.onSubmit,
    this.initialData,
    this.editing = false,
    super.key,
  });

  @override
  GroupFormState createState() {
    return GroupFormState();
  }
}

class GroupFormState extends State<GroupForm> {
  final _formKey = GlobalKey<FormState>();

  late final GroupDTO _formData;

  var _submitting = false;

  @override
  void initState() {
    super.initState();

    _formData = GroupDTO(
      name: widget.initialData?.name ?? '',
      description: widget.initialData?.description ?? '',
      private: widget.initialData?.private ?? false,
      planet: widget.initialData?.planet,
      difficulty: widget.initialData?.difficulty ?? Difficulty.trivial,
      startAt: widget.initialData?.startAt ?? DateTime.now(),
    );
  }

  void onBackPress() {
    if (widget.onBackPress != null) {
      widget.onBackPress!();
    }
  }

  void onSubmit() async {
    if (_formKey.currentState!.validate()) {
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
              labelText: AppLocalizations.of(context)!.groupName,
              hintText: AppLocalizations.of(context)!.groupNameHint,
            ),
            validator: (value) {
              final trimmedValue = value?.trim();

              if (trimmedValue == null || trimmedValue.isEmpty) {
                return AppLocalizations.of(context)!.groupNameNotEmpty;
              }

              if (trimmedValue.length > 50) {
                return AppLocalizations.of(context)!.groupNameMaxLength;
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
          // Description
          TextFormField(
            initialValue: _formData.description,
            enabled: !_submitting,
            minLines: 3,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.groupDescription,
              hintText: AppLocalizations.of(context)!.groupDescriptionHint,
            ),
            validator: (value) {
              final trimmedValue = value?.trim();

              if (trimmedValue == null) {
                return null;
              }

              if (trimmedValue.length > 1000) {
                return AppLocalizations.of(context)!.groupDescriptionMaxLength;
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _formData.description = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Difficulty
          if (!widget.editing) const SizedBox(height: 18),
          if (!widget.editing)
            FormField<Difficulty>(
              initialValue: _formData.difficulty,
              validator: (value) {
                return null;
              },
              builder: (FormFieldState<Difficulty> field) {
                return DropdownMenu<Difficulty>(
                  label: Text(AppLocalizations.of(context)!.groupDifficulty),
                  initialSelection: field.value,
                  expandedInsets: EdgeInsets.zero,
                  enabled: !_submitting,
                  errorText: field.errorText,
                  onSelected: (Difficulty? value) {
                    field.didChange(value);

                    setState(() {
                      _formData.difficulty = value!;
                    });
                  },
                  dropdownMenuEntries: Difficulty.values
                      .map<DropdownMenuEntry<Difficulty>>(
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
                  }).toList(),
                );
              },
            ),
          // Planet
          if (!widget.editing && widget.planets != null)
            const SizedBox(height: 22),
          if (!widget.editing && widget.planets != null)
            FormField<Planet>(
              initialValue: _formData.planet,
              validator: (value) {
                if (value == null) {
                  return AppLocalizations.of(context)!.groupPlanetNotEmpty;
                }

                return null;
              },
              builder: (FormFieldState<Planet> field) {
                return DropdownMenu<Planet>(
                  label: Text(AppLocalizations.of(context)!.groupPlanet),
                  initialSelection: field.value,
                  expandedInsets: EdgeInsets.zero,
                  enabled: !_submitting,
                  errorText: field.errorText,
                  onSelected: (Planet? value) {
                    field.didChange(value);

                    setState(() {
                      _formData.planet = value;
                    });
                  },
                  dropdownMenuEntries: widget.planets!
                      .map<DropdownMenuEntry<Planet>>((Planet planet) {
                    return DropdownMenuEntry<Planet>(
                        value: planet, label: planet.name);
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: 18),
          // Private
          FormField(
            initialValue: _formData.private,
            validator: (value) {
              return null;
            },
            builder: (FormFieldState<bool> field) {
              return SwitchListTile(
                title: Text(AppLocalizations.of(context)!.groupPrivate),
                subtitle: Text(AppLocalizations.of(context)!.groupPrivateHint),
                value: field.value!,
                onChanged: _submitting
                    ? null
                    : (value) {
                        field.didChange(value);

                        setState(() {
                          _formData.private = value;
                        });
                      },
              );
            },
          ),
          const SizedBox(height: 18),
          // Start at
          FormField<DateTime>(
            initialValue: _formData.startAt,
            validator: (value) {
              return null;
            },
            builder: (FormFieldState<DateTime> field) {
              return OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  "${AppLocalizations.of(context)!.groupStartAt} (${DateFormat.MMMMd().format(_formData.startAt)}, ${DateFormat.Hm().format(_formData.startAt)})",
                ),
                onPressed: () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    theme: const picker_theme.DatePickerTheme(
                      backgroundColor: ThemeColors.surface,
                      headerColor: ThemeColors.surface,
                      doneStyle: TextStyle(color: ThemeColors.primary),
                      cancelStyle: TextStyle(color: ThemeColors.primary),
                      itemStyle: TextStyle(color: ThemeColors.primary),
                    ),
                    locale:
                        Localizations.localeOf(context) == const Locale('fr')
                            ? LocaleType.fr
                            : LocaleType.en,
                    minTime: DateTime.now().subtract(
                      const Duration(hours: 1),
                    ),
                    maxTime: DateTime.now().add(
                      const Duration(days: 365),
                    ),
                    currentTime: DateTime.now(),
                    onConfirm: (date) {
                      field.didChange(date);

                      setState(() {
                        _formData.startAt = date;
                      });
                    },
                  );
                },
              );
            },
          ),
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
