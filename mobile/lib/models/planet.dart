import 'package:json_annotation/json_annotation.dart';

part 'planet.g.dart';

@JsonSerializable()
class Planet {
  final int id;

  final String name;

  final int? health;

  final int? maxHealth;

  final int players;

  final bool disabled;

  final int regeneration;

  final double positionX;

  final double positionY;

  final int helldiversID;

  Planet({
    required this.id,
    required this.name,
    this.health,
    this.maxHealth,
    required this.players,
    required this.disabled,
    required this.regeneration,
    required this.positionX,
    required this.positionY,
    required this.helldiversID,
  });

  factory Planet.fromJson(Map<String, dynamic> json) => _$PlanetFromJson(json);

  Map<String, dynamic> toJson() => _$PlanetToJson(this);
}
