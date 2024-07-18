import 'package:json_annotation/json_annotation.dart';

enum Feature {
  @JsonValue('map')
  map(
    'Map',
  ),

  @JsonValue('planet_list')
  planetList(
    'Planet List',
  );

  const Feature(
    this.code,
  );

  final String code;
}
