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

  Duration get estimatedTime {
    final durations = <Duration, int>{};

    if (objectiveTypes.isEmpty) {
      return Duration.zero;
    }

    for (final objective in objectiveTypes) {
      var duration = objective.duration;

      if (durations.containsKey(duration)) {
        durations[duration] = durations[duration]! + 1;
      } else {
        durations[duration] = 1;
      }
    }

    final sortedDurations = durations.entries.toList()
      ..sort(
        (a, b) => a.key.compareTo(b.key),
      );
    final mostCommonDuration = sortedDurations.last;

    return mostCommonDuration.key;
  }

  bool isMember(String steamUserId) {
    return groupUserMissions.any((groupUserMission) {
      return groupUserMission.groupUser?.user?.steamId == steamUserId;
    });
  }

  factory Mission.fromJson(Map<String, dynamic> json) =>
      _$MissionFromJson(json);

  Map<String, dynamic> toJson() => _$MissionToJson(this);
}
