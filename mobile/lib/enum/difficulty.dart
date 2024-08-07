import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/utils/theme_colors.dart';

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

  List<Color> get gradient {
    switch (this) {
      case Difficulty.trivial:
        return [
          ThemeColors.primary.shade50,
          ThemeColors.primary.shade100,
        ];
      case Difficulty.easy:
        return [
          ThemeColors.primary.shade50,
          ThemeColors.primary.shade100,
          ThemeColors.primary.shade200,
        ];
      case Difficulty.medium:
        return [
          ThemeColors.primary.shade50,
          ThemeColors.primary.shade100,
          ThemeColors.primary.shade200,
          ThemeColors.primary.shade300,
        ];
      case Difficulty.challenging:
        return [
          ThemeColors.primary.shade50,
          ThemeColors.primary.shade100,
          ThemeColors.primary.shade200,
          ThemeColors.primary.shade300,
          ThemeColors.primary.shade400,
        ];
      case Difficulty.hard:
        return [
          ThemeColors.primary.shade100,
          ThemeColors.primary.shade200,
          ThemeColors.primary.shade300,
          ThemeColors.primary.shade400,
          ThemeColors.primary.shade500,
        ];
      case Difficulty.extreme:
        return [
          ThemeColors.primary.shade200,
          ThemeColors.primary.shade300,
          ThemeColors.primary.shade400,
          ThemeColors.primary.shade500,
          ThemeColors.primary.shade600,
        ];
      case Difficulty.suicideMission:
        return [
          ThemeColors.primary.shade300,
          ThemeColors.primary.shade400,
          ThemeColors.primary.shade500,
          ThemeColors.primary.shade600,
          ThemeColors.primary.shade700,
        ];
      case Difficulty.impossible:
        return [
          ThemeColors.primary.shade400,
          ThemeColors.primary.shade500,
          ThemeColors.primary.shade600,
          ThemeColors.primary.shade700,
          ThemeColors.primary.shade800,
        ];
      case Difficulty.helldive:
        return [
          ThemeColors.primary.shade500,
          ThemeColors.primary.shade600,
          ThemeColors.primary.shade700,
          ThemeColors.primary.shade800,
          ThemeColors.primary.shade900,
        ];
    }
  }

  String translatedName(BuildContext context) {
    switch (this) {
      case Difficulty.trivial:
        return AppLocalizations.of(context)!.difficultyTrivial;
      case Difficulty.easy:
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
