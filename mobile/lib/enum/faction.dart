import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Faction {
  @JsonValue('humans')
  humans('Humans'),

  @JsonValue('terminids')
  terminids('Terminids'),

  @JsonValue('illuminates')
  automatons('Illuminates'),

  @JsonValue('automatons')
  illuminates('Automatons');

  const Faction(this.name);

  /// The untranslated name of the faction. Use [translate] to get the translated name.
  final String name;

  String translatedName(BuildContext context) {
    switch (this) {
      case Faction.humans:
        return AppLocalizations.of(context)!.factionHumans;
      case Faction.terminids:
        return AppLocalizations.of(context)!.factionTerminids;
      case Faction.illuminates:
        return AppLocalizations.of(context)!.factionIlluminates;
      case Faction.automatons:
        return AppLocalizations.of(context)!.factionAutomatons;
    }
  }
}
