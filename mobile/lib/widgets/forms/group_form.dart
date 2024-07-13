import 'package:flutter/material.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/models/planet.dart';

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
    required this.planets,
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
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'The name of your group',
            ),
            validator: (value) {
              final trimmedValue = value?.trim();

              if (trimmedValue == null || trimmedValue.isEmpty) {
                return 'Please enter some text';
              }

              if (trimmedValue.length > 100) {
                return 'The name must be less than 100 characters';
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _formData.name = value;
              });
            },
          ),
          // Description
          TextFormField(
            initialValue: _formData.description,
            enabled: !_submitting,
            minLines: 3,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'The optional description of your group',
            ),
            validator: (value) {
              final trimmedValue = value?.trim();

              if (trimmedValue == null) {
                return null;
              }

              if (trimmedValue.length > 1000) {
                return 'The description must be less than 1000 characters';
              }

              return null;
            },
            onChanged: (value) {
              setState(() {
                _formData.description = value;
              });
            },
          ),
          // Private
          FormField(
            initialValue: _formData.private,
            validator: (value) {
              return null;
            },
            builder: (FormFieldState<bool> field) {
              return SwitchListTile(
                title: Text("Private"),
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
          // Start at
          InputDatePickerFormField(
            initialDate: _formData.startAt,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(
              const Duration(days: 365),
            ),
            onDateSubmitted: (DateTime value) {
              setState(() {
                _formData.startAt = value;
              });
            },
          ),
          // Difficulty
          FormField<Difficulty>(
            initialValue: _formData.difficulty,
            validator: (value) {
              return null;
            },
            builder: (FormFieldState<Difficulty> field) {
              return DropdownMenu<Difficulty>(
                label: Text("Difficulty"),
                initialSelection: field.value,
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
                  );
                }).toList(),
              );
            },
          ),
          // Planet
          if (widget.planets != null)
            FormField<Planet>(
              initialValue: _formData.planet,
              validator: (value) {
                if (value == null) {
                  return 'Please select a planet';
                }

                return null;
              },
              builder: (FormFieldState<Planet> field) {
                return DropdownMenu<Planet>(
                  label: Text("Planet"),
                  initialSelection: field.value,
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
          if (widget.onBackPress != null)
            ElevatedButton(
              onPressed: _submitting ? null : onBackPress,
              child: const Text('Back'),
            ),
          ElevatedButton(
            onPressed: _submitting ? null : onSubmit,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
