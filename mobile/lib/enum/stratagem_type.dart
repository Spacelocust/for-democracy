import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StratagemType {
  @JsonValue('supply')
  supply(
    'Supply',
  ),

  @JsonValue('mission')
  mission(
    'Mission',
  ),

  @JsonValue('defensive')
  defensive(
    'Defensive',
  ),

  @JsonValue('offensive')
  offensive(
    'Offensive',
  );

  const StratagemType(
    this.name,
  );

  /// The untranslated name of the difficulty. Use [translatedName] to get the translated name.
  final String name;

  String translatedName(BuildContext context) {
    switch (this) {
      case StratagemType.supply:
        return AppLocalizations.of(context)!.stratagemTypeSupply;
      case StratagemType.mission:
        return AppLocalizations.of(context)!.stratagemTypeMission;
      case StratagemType.defensive:
        return AppLocalizations.of(context)!.stratagemTypeDefensive;
      case StratagemType.offensive:
        return AppLocalizations.of(context)!.stratagemTypeOffensive;
    }
  }
}
