import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/utils/planets.dart';

part 'sector.g.dart';

@JsonSerializable()
class Sector {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Name')
  final String name;

  @JsonKey(name: 'Planets', fromJson: planetsFromJson)
  final List<Planet>? planets;

  Sector({
    required this.id,
    required this.name,
    required this.planets,
  });

  factory Sector.fromJson(Map<String, dynamic> json) => _$SectorFromJson(json);

  Map<String, dynamic> toJson() => _$SectorToJson(this);
}
