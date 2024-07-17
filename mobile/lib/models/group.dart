import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/models/group_user.dart';
import 'package:mobile/models/mission.dart';
import 'package:mobile/models/planet.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  static const int maxPlayers = 4;

  @JsonKey(required: true, name: 'ID')
  final int id;

  // This should be allowed to be null, so that the code isn't leaked on the mobile app to users without the proper permissions
  @JsonKey(name: 'Code')
  final String? code;

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
    this.code,
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

  bool get isFull => groupUsers.length >= maxPlayers;

  bool isOwner(String userSteamId) => groupUsers.any(
      (groupUser) => groupUser.owner && groupUser.user?.steamId == userSteamId);

  bool isMember(String userSteamId) =>
      groupUsers.any((groupUser) => groupUser.user?.steamId == userSteamId);

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
