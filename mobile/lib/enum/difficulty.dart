import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Difficulty {
  @JsonValue('trivial')
  trivial(
    'trivial',
  ),

  @JsonValue('easy')
  easy(
    'easy',
  ),

  @JsonValue('medium')
  medium(
    'medium',
  ),

  @JsonValue('challenging')
  challenging(
    'challenging',
  ),

  @JsonValue('hard')
  hard(
    'hard',
  ),

  @JsonValue('extreme')
  extreme(
    'extreme',
  ),

  @JsonValue('suicide_mission')
  suicideMission(
    'suicide_mission',
  ),

  @JsonValue('impossible')
  impossible(
    'impossible',
  ),

  @JsonValue('helldive')
  helldive(
    'helldive',
  );

  const Difficulty(
    this.code,
  );

  /// The enum code of the difficulty. Use [translatedName] to get the translated name.
  final String code;

  String get logo => 'assets/images/difficulties/${code.toLowerCase()}.png';

  String translatedName(BuildContext context) {
    switch (this) {
      case Difficulty.easy:
        return AppLocalizations.of(context)!.difficultyTrivial;
      case Difficulty.trivial:
        return AppLocalizations.of(context)!.difficultyEasy;
      case Difficulty.medium:
        return AppLocalizations.of(context)!.difficultyMedium;
      case Difficulty.challenging:
        return AppLocalizations.of(context)!.difficultyChallenging;
      case Difficulty.hard:
        return AppLocalizations.of(context)!.difficultyHard;
      case Difficulty.extreme:
        return AppLocalizations.of(context)!.difficultyExtreme;
      case Difficulty.suicideMission:
        return AppLocalizations.of(context)!.difficultySuicideMission;
      case Difficulty.impossible:
        return AppLocalizations.of(context)!.difficultyImpossible;
      case Difficulty.helldive:
        return AppLocalizations.of(context)!.difficultyHelldive;
    }
  }
}
