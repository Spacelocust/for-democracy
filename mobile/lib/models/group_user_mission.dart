import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/models/group_user.dart';
import 'package:mobile/models/mission.dart';
import 'package:mobile/models/stratagem.dart';

part 'group_user_mission.g.dart';

@JsonSerializable()
class GroupUserMission {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(name: 'Mission')
  final Mission? mission;

  @JsonKey(name: 'GroupUser')
  final GroupUser? groupUser;

  @JsonKey(name: 'Stratagems')
  final List<Stratagem>? stratagems;

  GroupUserMission({
    required this.id,
    this.mission,
    this.groupUser,
    this.stratagems,
  });

  factory GroupUserMission.fromJson(Map<String, dynamic> json) =>
      _$GroupUserMissionFromJson(json);

  Map<String, dynamic> toJson() => _$GroupUserMissionToJson(this);
}
