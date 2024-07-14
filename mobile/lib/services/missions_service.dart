import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/dto/mission_dto.dart';
import 'package:mobile/dto/mission_user_dto.dart';
import 'package:mobile/models/group_user_mission.dart';
import 'package:mobile/models/mission.dart';
import 'package:mobile/services/api_service.dart';

abstract class MissionsService {
  static const String missionsUrl = '/missions';

  static String url = '${dotenv.get(APIService.baseUrlEnv)}$missionsUrl';

  static Future<Mission> createMission(int groupId, MissionDTO data) async {
    var dio = APIService.getDio();
    var group = await dio.post(missionsUrl, data: {
      'groupID': groupId,
      'name': data.name,
      'instructions': data.instructions,
      'objectiveTypes': data.objectives.map((e) => e.code).toList(),
    });

    return Mission.fromJson(group.data);
  }

  static Future<Mission> editMission(
    int groupId,
    int missionId,
    MissionDTO data,
  ) async {
    var dio = APIService.getDio();
    var group = await dio.put("$missionsUrl/$missionId", data: {
      'groupID': groupId,
      'name': data.name,
      'instructions': data.instructions,
      'objectiveTypes': data.objectives.map((e) => e.code).toList(),
    });

    return Mission.fromJson(group.data);
  }

  static Future<void> deleteMission(int missionId) async {
    var dio = APIService.getDio();

    await dio.delete("$missionsUrl/$missionId");
  }

  static Future<GroupUserMission> joinMission(
    int missionId,
    MissionUserDTO data,
  ) async {
    var dio = APIService.getDio();
    var mission = await dio.post("$missionsUrl/$missionId/join", data: {
      'stratagems': data.stratagems.map((e) => e.id).toList(),
    });

    return GroupUserMission.fromJson(mission.data);
  }

  static Future<void> leaveMission(int missionId) async {
    var dio = APIService.getDio();

    await dio.post("$missionsUrl/$missionId/leave");
  }
}
