import 'package:json_annotation/json_annotation.dart';

part 'planet.g.dart';

@JsonSerializable()
class Planet {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Name')
  final String name;

  @JsonKey(name: 'MaxHealth')
  final int? maxHealth;

  @JsonKey(required: true, name: 'Disabled')
  final bool disabled;

  @JsonKey(required: true, name: 'Regeneration')
  final int regeneration;

  @JsonKey(required: true, name: 'PositionX')
  final double positionX;

  @JsonKey(required: true, name: 'PositionY')
  final double positionY;

  @JsonKey(required: true, name: 'HelldiversID')
  final int helldiversID;

  Planet({
    required this.id,
    required this.name,
    this.maxHealth,
    required this.disabled,
    required this.regeneration,
    required this.positionX,
    required this.positionY,
    required this.helldiversID,
  });

  factory Planet.fromJson(Map<String, dynamic> json) => _$PlanetFromJson(json);

  Map<String, dynamic> toJson() => _$PlanetToJson(this);
}
