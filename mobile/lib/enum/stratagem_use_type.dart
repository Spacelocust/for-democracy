import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StratagemUseType {
  @JsonValue('self')
  self(
    'Self',
  ),

  @JsonValue('team')
  team(
    'Team',
  ),

  @JsonValue('shared')
  shared(
    'Shared',
  );

  const StratagemUseType(
    this.name,
  );

  /// The untranslated name of the difficulty. Use [translatedName] to get the translated name.
  final String name;

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
