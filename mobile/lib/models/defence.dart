import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/faction.dart';
import 'package:mobile/models/planet.dart';

part 'defence.g.dart';

@JsonSerializable()
class Defence {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(name: 'Players')
  final int players;

  @JsonKey(required: true, name: 'StartAt')
  final DateTime startAt;

  @JsonKey(required: true, name: 'EndAt')
  final DateTime endAt;

  @JsonKey(required: true, name: 'EnemyFaction')
  final Faction enemyFaction;

  @JsonKey(required: true, name: 'Health')
  final int health;

  @JsonKey(required: true, name: 'MaxHealth')
  final int maxHealth;

  @JsonKey(required: true, name: 'ImpactPerHour')
  final double impactPerHour;

  @JsonKey(name: 'Planet')
  final Planet? planet;

  @JsonKey(required: true, name: 'HelldiversID')
  final int helldiversID;

  Defence({
    required this.id,
    required this.players,
    required this.startAt,
    required this.endAt,
    required this.enemyFaction,
    required this.health,
    required this.maxHealth,
    required this.impactPerHour,
    this.planet,
    required this.helldiversID,
  });

  double getEnemyImpactPerHour() => (((1 / 24) * maxHealth) / 3600);

  double getEnemyHealthPercentage() {
    int elapsedTime = endAt.difference(DateTime.now()).inSeconds;
    return 1 - (((elapsedTime / 3600) * getEnemyImpactPerHour()) / 100);
  }

  double getHealthPercentage() => 1 - (health / maxHealth);

  double getRequiredImpactPerHour() {
    int timeLeft = endAt.difference(DateTime.now()).inSeconds;
    double healthLeft = ((health * 100) / maxHealth);

    return (healthLeft / (timeLeft / 3600));
  }

  factory Defence.fromJson(Map<String, dynamic> json) =>
      _$DefenceFromJson(json);

  Map<String, dynamic> toJson() => _$DefenceToJson(this);
}
