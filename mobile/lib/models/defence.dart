import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';

part 'defence.g.dart';

@JsonSerializable()
class Defence {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Health')
  final int health;

  @JsonKey(required: true, name: 'StartAt')
  final DateTime startAt;

  @JsonKey(required: true, name: 'EndAt')
  final DateTime endAt;

  @JsonKey(required: true, name: 'EnemyFaction')
  final Faction enemyFaction;

  @JsonKey(required: true, name: 'EnemyHealth')
  final int enemyHealth;

  @JsonKey(required: true, name: 'EnemyMaxHealth')
  final int enemyMaxHealth;

  @JsonKey(name: 'Planet')
  final Planet? planet;

  @JsonKey(required: true, name: 'HelldiversID')
  final int helldiversID;

  Defence({
    required this.id,
    required this.health,
    required this.startAt,
    required this.endAt,
    required this.enemyFaction,
    required this.enemyHealth,
    required this.enemyMaxHealth,
    this.planet,
    required this.helldiversID,
  });

  factory Defence.fromJson(Map<String, dynamic> json) =>
      _$DefenceFromJson(json);

  Map<String, dynamic> toJson() => _$DefenceToJson(this);
}
