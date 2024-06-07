import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/planet.dart';

part 'liberation.g.dart';

@JsonSerializable()
class Liberation {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Health')
  final int health;

  @JsonKey(required: true, name: 'StartAt')
  final int previousHealth;

  @JsonKey(name: 'Players')
  final int players;

  @JsonKey(name: 'Planet')
  final Planet? planet;

  @JsonKey(required: true, name: 'HelldiversID')
  final int helldiversID;

  Liberation({
    required this.id,
    required this.health,
    required this.players,
    required this.previousHealth,
    this.planet,
    required this.helldiversID,
  });

  factory Liberation.fromJson(Map<String, dynamic> json) =>
      _$LiberationFromJson(json);

  Map<String, dynamic> toJson() => _$LiberationToJson(this);
}
