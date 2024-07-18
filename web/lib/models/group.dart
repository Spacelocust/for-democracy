import 'package:app/enum/difficulty.dart';
import 'package:app/models/group_user.dart';
import 'package:app/models/mission.dart';
import 'package:app/models/planet.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(name: 'Code')
  final String code;

  @JsonKey(required: true, name: 'Name')
  final String name;

  @JsonKey(name: 'Description')
  final String? description;

  @JsonKey(required: true, name: 'Public')
  final bool public;

  @JsonKey(required: true, name: 'StartAt')
  final DateTime startAt;

  @JsonKey(required: true, name: 'Difficulty')
  final Difficulty difficulty;

  @JsonKey(required: true, name: 'Missions')
  final List<Mission> missions;

  @JsonKey(required: true, name: 'GroupUsers')
  final List<GroupUser> groupUsers;

  @JsonKey(required: true, name: 'Planet')
  final Planet planet;

  Group({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.public,
    required this.startAt,
    required this.difficulty,
    required this.missions,
    required this.groupUsers,
    required this.planet,
  });

  GroupUser? get owner => groupUsers.firstWhere((element) => element.owner);

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
