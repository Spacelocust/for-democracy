import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/utils/planets.dart';

part 'effect.g.dart';

@JsonSerializable()
class Effect {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Name')
  final String name;

  @JsonKey(name: 'Description')
  final String? description;

  @JsonKey(name: 'Planets', fromJson: planetsFromJson)
  final List<Planet> planets;

  Effect({
    required this.id,
    required this.name,
    this.description,
    required this.planets,
  });

  factory Effect.fromJson(Map<String, dynamic> json) => _$EffectFromJson(json);

  Map<String, dynamic> toJson() => _$EffectToJson(this);
}
