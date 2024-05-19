import 'package:json_annotation/json_annotation.dart';

part 'statistic.g.dart';

@JsonSerializable()
class Statistic {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'PlanetID')
  final int planetId;

  @JsonKey(required: true, name: 'MissionsWon')
  final int missionsWon;

  @JsonKey(required: true, name: 'MissionTime')
  final int missionTime;

  @JsonKey(required: true, name: 'BugKills')
  final int bugKills;

  @JsonKey(required: true, name: 'AutomatonKills')
  final int automatonKills;

  @JsonKey(required: true, name: 'IlluminateKills')
  final int illuminateKills;

  @JsonKey(required: true, name: 'BulletsFired')
  final int bulletsFired;

  @JsonKey(required: true, name: 'BulletsHit')
  final int bulletsHit;

  @JsonKey(required: true, name: 'TimePlayed')
  final int timePlayed;

  @JsonKey(required: true, name: 'Deaths')
  final int deaths;

  @JsonKey(required: true, name: 'Revives')
  final int revives;

  @JsonKey(required: true, name: 'FriendlyKills')
  final int friendlyKills;

  @JsonKey(required: true, name: 'MissionSuccessRate')
  final int missionSuccessRate;

  @JsonKey(required: true, name: 'Accuracy')
  final int accuracy;

  Statistic({
    required this.id,
    required this.planetId,
    required this.missionsWon,
    required this.missionTime,
    required this.bugKills,
    required this.automatonKills,
    required this.illuminateKills,
    required this.bulletsFired,
    required this.bulletsHit,
    required this.timePlayed,
    required this.deaths,
    required this.revives,
    required this.friendlyKills,
    required this.missionSuccessRate,
    required this.accuracy,
  });

  factory Statistic.fromJson(Map<String, dynamic> json) =>
      _$StatisticFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticToJson(this);
}
