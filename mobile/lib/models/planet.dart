import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/defence.dart';
import 'package:mobile/models/effect.dart';
import 'package:mobile/models/liberation.dart';
import 'package:mobile/models/sector.dart';
import 'package:mobile/models/statistic.dart';
import 'package:mobile/models/waypoint.dart';

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

  @JsonKey(name: 'Owner')
  final Faction owner;

  @JsonKey(name: 'InitialOwner')
  final Faction initialOwner;

  @JsonKey(name: 'ImageURL')
  final String imageUrl;

  @JsonKey(name: 'BackgroundURL')
  final String backgroundUrl;

  @JsonKey(name: 'Waypoints')
  final List<Waypoint> waypoints;

  @JsonKey(required: true, name: 'Statistic')
  final Statistic statistic;

  @JsonKey(name: 'Liberation')
  final Liberation? liberation;

  @JsonKey(name: 'Defence')
  final Defence? defence;

  @JsonKey(required: true, name: 'Effects')
  final List<Effect> effects;

  @JsonKey(required: true, name: 'Sector')
  final Sector sector;

  Planet({
    required this.id,
    required this.name,
    this.maxHealth,
    required this.disabled,
    required this.regeneration,
    required this.positionX,
    required this.positionY,
    required this.helldiversID,
    required this.owner,
    required this.initialOwner,
    required this.imageUrl,
    required this.backgroundUrl,
    required this.waypoints,
    required this.statistic,
    this.liberation,
    this.defence,
    required this.effects,
    required this.sector,
  });

  int? get players {
    if (liberation != null) {
      return liberation!.players;
    }

    if (defence != null) {
      return defence!.players;
    }

    return null;
  }

  bool get hasLiberation => liberation != null;

  bool get hasDefence => defence != null;

  bool get hasLiberationOrDefence => hasLiberation || hasDefence;

  double scaleXTo(double to) => (positionX + 1) * to;

  double scaleYTo(double to) => (positionY + 1) * to;

  factory Planet.fromJson(Map<String, dynamic> json) => _$PlanetFromJson(json);

  Map<String, dynamic> toJson() => _$PlanetToJson(this);
}
