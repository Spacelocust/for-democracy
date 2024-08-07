import 'package:app/enum/faction.dart';
import 'package:app/models/defence.dart';
import 'package:app/models/liberation.dart';
import 'package:flutter/material.dart';
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

  @JsonKey(name: 'Liberation')
  final Liberation? liberation;

  @JsonKey(name: 'Defence')
  final Defence? defence;

  Planet({
    required this.id,
    required this.name,
    this.maxHealth,
    required this.disabled,
    required this.positionX,
    required this.positionY,
    required this.helldiversID,
    required this.owner,
    required this.initialOwner,
    required this.imageUrl,
    required this.backgroundUrl,
    this.liberation,
    this.defence,
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

  Color get color => owner.color;

  double scaleXTo(double to) => (positionX + 1) * to;

  double scaleYTo(double to) => (positionY + 1) * to;

  double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 60.0;

  double getLiberationPercentage() => 1 - (liberation!.health / maxHealth!);

  factory Planet.fromJson(Map<String, dynamic> json) => _$PlanetFromJson(json);

  Map<String, dynamic> toJson() => _$PlanetToJson(this);
}
