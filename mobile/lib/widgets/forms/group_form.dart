import 'package:flutter/material.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/models/planet.dart';

class GroupForm extends StatefulWidget {
  /// The list of planets to choose from.
  final List<Planet> planets;

  final Function()? onBackPress;

  final Future<void> Function(GroupDTO formData)? onSubmit;

  const GroupForm({
    required this.planets,
    this.onBackPress,
    this.onSubmit,
    super.key,
  });

  @override
  GroupFormState createState() {
    return GroupFormState();
  }
}

class GroupFormState extends State<GroupForm> {
  final _formKey = GlobalKey<FormState>();

  var _submitting = false;

  final _formData = GroupDTO(
    name: '',
    description: null,
    isPrivate: false,
    planet: null,
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'The name of your group',
            ),
            enabled: !_submitting,
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
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'The optional description of your group',
            ),
            minLines: 3,
            maxLines: null,
            enabled: !_submitting,
            keyboardType: TextInputType.multiline,
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
          FormField(
            initialValue: false,
            builder: (FormFieldState<bool> field) {
              return SwitchListTile(
                title: Text("Private"),
                value: field.value!,
                onChanged: _submitting
                    ? null
                    : (value) {
                        field.didChange(value);

                        setState(() {
                          _formData.isPrivate = value;
                        });
                      },
              );
            },
          ),
          FormField<Planet>(
            validator: (value) {
              if (value == null) {
                return 'Please select a planet';
              }

              return null;
            },
            builder: (FormFieldState<Planet> field) {
              return DropdownMenu<Planet>(
                label: Text("Planet"),
                initialSelection: null,
                enabled: !_submitting,
                onSelected: (Planet? value) {
                  field.didChange(value);

                  setState(() {
                    _formData.planet = value;
                  });
                },
                errorText: field.errorText,
                dropdownMenuEntries: widget.planets
                    .map<DropdownMenuEntry<Planet>>((Planet planet) {
                  return DropdownMenuEntry<Planet>(
                      value: planet, label: planet.name);
                }).toList(),
              );
            },
          ),
          if (widget.onBackPress != null)
            ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () {
                      widget.onBackPress!();
                    },
              child: const Text('Back'),
            ),
          ElevatedButton(
            onPressed: _submitting
                ? null
                : () async {
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
                  },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
