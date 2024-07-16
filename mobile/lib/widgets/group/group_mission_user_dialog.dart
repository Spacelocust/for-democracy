import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/dto/mission_user_dto.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/models/mission.dart';
import 'package:mobile/models/stratagem.dart';
import 'package:mobile/screens/group_screen.dart';
import 'package:mobile/services/missions_service.dart';
import 'package:mobile/utils/snackbar.dart';
import 'package:mobile/utils/theme_colors.dart';
import 'package:mobile/widgets/components/text_style_arame.dart';
import 'package:mobile/widgets/stratagem/stratagem_image.dart';

class GroupMissionUserDialog extends StatefulWidget {
  static const maxStratagems = 4;

  /// The group that the mission belongs to.
  final Group group;

  /// The mission that the user is joining.
  final Mission mission;

  /// The stratagems that the user can choose from.
  final List<Stratagem> stratagems;

  /// The initial data to populate the form with.
  final MissionUserDTO? initialData;

  /// Whether the dialog is for editing an existing mission.
  final bool editing;

  const GroupMissionUserDialog({
    super.key,
    required this.group,
    required this.mission,
    required this.stratagems,
    this.initialData,
    this.editing = false,
  });

  @override
  State<GroupMissionUserDialog> createState() => _GroupMissionUserDialogState();
}

class _GroupMissionUserDialogState extends State<GroupMissionUserDialog> {
  final _formKey = GlobalKey<FormState>();

  late final MissionUserDTO _formData;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    List<Stratagem> stratagems = [];

    if (widget.initialData != null) {
      stratagems = widget.initialData!.stratagems.map((e) {
        return widget.stratagems.firstWhere((s) => s.id == e.id);
      }).toList();
    }

    _formData = MissionUserDTO(
      stratagems: stratagems,
    );
  }

  List<Widget> _buildStratagems() {
    final stratagemTiles = <Widget>[];

    for (final stratagem in widget.stratagems) {
      bool isEnabled = !_submitting;
      bool isSelected = _formData.stratagems.contains(stratagem);

      if (!isSelected && isEnabled) {
        isEnabled =
            _formData.stratagems.length < GroupMissionUserDialog.maxStratagems;
      }

      final stratagemImage = StratagemImage(
        stratagem: stratagem,
        borderColor: isSelected ? ThemeColors.primary : Colors.white,
      );

      stratagemTiles.add(
        CheckboxListTile(
          value: _formData.stratagems.contains(stratagem),
          enabled: isEnabled,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _formData.stratagems.add(stratagem);
              } else {
                _formData.stratagems.remove(stratagem);
              }
            });
          },
          secondary: isEnabled
              ? stratagemImage
              : ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.modulate,
                  ),
                  child: stratagemImage,
                ),
          title: Text(stratagem.name),
          subtitle: Text(
            stratagem.useType.translatedName(context),
          ),
        ),
      );
    }

    return stratagemTiles;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    List<Widget> stratagemTiles = [
      ListTile(
        title: Text(
          AppLocalizations.of(context)!.missionStratagems,
          style: const TextStyleArame(),
        ),
      ),
      ..._buildStratagems(),
    ];

    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.editing
            ? AppLocalizations.of(context)!.missionUpdateParticipation
            : AppLocalizations.of(context)!.missionJoin,
        style: const TextStyleArame(),
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          height: height * 0.6,
          child: ListView.builder(
            itemCount: stratagemTiles.length,
            itemBuilder: (context, index) {
              return stratagemTiles[index];
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: _submitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(AppLocalizations.of(context)!.close),
        ),
        OutlinedButton.icon(
          onPressed: _submitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _submitting = true;
                    });

                    showSnackBar(
                      context,
                      widget.editing
                          ? AppLocalizations.of(context)!
                              .missionUpdatingParticipation
                          : AppLocalizations.of(context)!.missionJoining,
                      showCloseIcon: false,
                      duration: const Duration(
                        // Their phone will run out of battery before this finishes
                        days: 365,
                      ),
                    );

                    try {
                      if (widget.editing) {
                        await MissionsService.editMissionParticipation(
                          widget.mission.id,
                          _formData,
                        );
                      } else {
                        await MissionsService.joinMission(
                          widget.mission.id,
                          _formData,
                        );
                      }

                      if (!context.mounted) {
                        return;
                      }

                      showSnackBar(
                        context,
                        widget.editing
                            ? AppLocalizations.of(context)!
                                .missionUpdatedParticipation
                            : AppLocalizations.of(context)!.missionJoined,
                      );

                      Navigator.of(context).pop();

                      context.replace(
                        context.namedLocation(
                          GroupScreen.routeName,
                          pathParameters: {
                            'groupId': widget.group.id.toString(),
                          },
                        ),
                      );
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
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      showSnackBar(
                        context,
                        AppLocalizations.of(context)!.somethingWentWrong,
                      );
                    } finally {
                      setState(() {
                        _submitting = false;
                      });
                    }
                  }
                },
          icon: Icon(widget.editing ? Icons.save : Icons.group_add),
          label: Text(
            widget.editing
                ? AppLocalizations.of(context)!.save
                : AppLocalizations.of(context)!.join,
          ),
        ),
      ],
    );
  }
}
