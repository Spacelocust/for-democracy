import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Faction {
  @JsonValue('humans')
  humans(
    'humans',
    Color(0xff6bb7ea),
    Color(0xff219ffb),
  ),

  @JsonValue('terminids')
  terminids(
    'terminids',
    Color(0xffffc000),
    Color(0xffc18700),
  ),

  @JsonValue('illuminates')
  illuminates(
    'illuminates',
    Color(0xff8300ff),
    Color(0xffb400ff),
  ),

  @JsonValue('automatons')
  automatons(
    'automatons',
    Color(0xfffe6d6a),
    Color(0xffcb4745),
  );

  const Faction(
    this.code,
    this.color,
    this.secondaryColor,
  );

  /// The code of the faction. Use [translatedName] to get the translated name.
  final String code;

  final Color color;

  final Color secondaryColor;

  String get logo => 'assets/images/factions/${code.toLowerCase()}.png';

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
