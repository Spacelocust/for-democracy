import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StratagemKey {
  @JsonValue('up')
  up(
    'up',
  ),

  @JsonValue('right')
  right(
    'right',
  ),

  @JsonValue('down')
  down(
    'down',
  ),

  @JsonValue('left')
  left(
    'left',
  );

  const StratagemKey(
    this.code,
  );

  /// The code of the key. Use [translatedName] to get the translated name.
  final String code;

  String get icon => 'assets/images/stratagem_keys/${code.toLowerCase()}.png';

  String translatedName(BuildContext context) {
    switch (this) {
      case StratagemKey.up:
        return AppLocalizations.of(context)!.up;
      case StratagemKey.right:
        return AppLocalizations.of(context)!.right;
      case StratagemKey.down:
        return AppLocalizations.of(context)!.down;
      case StratagemKey.left:
        return AppLocalizations.of(context)!.left;
    }
  }
}
