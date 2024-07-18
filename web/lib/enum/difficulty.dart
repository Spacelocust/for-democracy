import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';

enum Difficulty {
  @JsonValue('trivial')
  trivial(
    'Trivial',
  ),

  @JsonValue('easy')
  easy(
    'Easy',
  ),

  @JsonValue('medium')
  medium(
    'Medium',
  ),

  @JsonValue('challenging')
  challenging(
    'Challenging',
  ),

  @JsonValue('hard')
  hard(
    'Hard',
  ),

  @JsonValue('extreme')
  extreme(
    'Extreme',
  ),

  @JsonValue('suicide_mission')
  suicideMission(
    'Suicide Mission',
  ),

  @JsonValue('impossible')
  impossible(
    'Impossible',
  ),

  @JsonValue('helldive')
  helldive(
    'Helldive',
  );

  const Difficulty(
    this.name,
  );

  /// The untranslated name of the difficulty. Use [translatedName] to get the translated name.
  final String name;

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
