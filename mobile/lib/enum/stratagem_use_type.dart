import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StratagemUseType {
  @JsonValue('self')
  self(
    'self',
  ),

  @JsonValue('team')
  team(
    'team',
  ),

  @JsonValue('shared')
  shared(
    'shared',
  );

  const StratagemUseType(
    this.code,
  );

  /// The code of the stratagem use type. Use [translatedName] to get the translated name.
  final String code;

  String translatedName(BuildContext context) {
    switch (this) {
      case StratagemUseType.self:
        return AppLocalizations.of(context)!.stratagemUseTypeSelf;
      case StratagemUseType.team:
        return AppLocalizations.of(context)!.stratagemUseTypeTeam;
      case StratagemUseType.shared:
        return AppLocalizations.of(context)!.stratagemUseTypeShared;
    }
  }
}
