import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Faction {
  @JsonValue('humans')
  humans(
    'Humans',
    Color(0xff6bb7ea),
  ),

  @JsonValue('terminids')
  terminids(
    'Terminids',
    Color(0xffffc000),
  ),

  @JsonValue('illuminates')
  automatons(
    'Illuminates',
    Color(0xff8300ff),
  ),

  @JsonValue('automatons')
  illuminates(
    'Automatons',
    Color(0xfffe6d6a),
  ),
  ;

  const Faction(
    this.name,
    this.color,
  );

  /// The untranslated name of the faction. Use [translatedName] to get the translated name.
  final String name;

  final Color color;

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
