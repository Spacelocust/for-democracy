import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/objective_type.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/models/group_user_mission.dart';

part 'mission.g.dart';

@JsonSerializable()
class Mission {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(required: true, name: 'Name')
  final String name;

  @JsonKey(name: 'Instructions')
  final String? instructions;

  @JsonKey(required: true, name: 'ObjectiveTypes')
  final List<ObjectiveType> objectiveTypes;

  @JsonKey(name: 'Group')
  final Group? group;

  @JsonKey(required: true, name: 'GroupUserMissions')
  final List<GroupUserMission> groupUserMissions;

  Mission({
    required this.id,
    required this.name,
    this.instructions,
    required this.objectiveTypes,
    this.group,
    required this.groupUserMissions,
  });

  factory Mission.fromJson(Map<String, dynamic> json) =>
      _$MissionFromJson(json);

  Map<String, dynamic> toJson() => _$MissionToJson(this);
}
