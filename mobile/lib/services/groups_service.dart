import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/models/group_user.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/utils/date.dart';

abstract class GroupsService {
  static const String groupsUrl = '/groups';

  static String url = '${dotenv.get(APIService.baseUrlEnv)}$groupsUrl';

  static Future<List<Group>> getGroups() async {
    var dio = APIService.getDio();
    var groups = await dio.get(groupsUrl);
    var groupsData = groups.data as List<dynamic>;

    return groupsData.map((group) => Group.fromJson(group)).toList();
  }

  static Future<Group> getGroup(int groupId) async {
    var dio = APIService.getDio();
    var group = await dio.get('$groupsUrl/$groupId');

    return Group.fromJson(group.data);
  }

  static Future<Group> createGroup(GroupDTO data) async {
    var dio = APIService.getDio();
    var group = await dio.post(groupsUrl, data: {
      'name': data.name,
      'description': data.description,
      'public': !data.private,
      'planetId': data.planet!.id,
      'difficulty': data.difficulty.code,
      'startAt': formatDateForAPI(data.startAt),
    });

    return Group.fromJson(group.data);
  }

  static Future<Group> editGroup(int groupId, GroupDTO data) async {
    var dio = APIService.getDio();
    var group = await dio.put("$groupsUrl/$groupId", data: {
      'name': data.name,
      'description': data.description,
      'public': !data.private,
      'planetId': data.planet!.id,
      'difficulty': data.difficulty.code,
      'startAt': formatDateForAPI(data.startAt),
    });

    return Group.fromJson(group.data);
  }

  static Future<GroupUser> deleteGroup(int groupId) async {
    var dio = APIService.getDio();
    var groupUser = await dio.delete("$groupsUrl/$groupId");

    return GroupUser.fromJson(groupUser.data);
  }

  static Future<GroupUser> joinGroup(int groupId) async {
    var dio = APIService.getDio();
    var groupUser = await dio.post("$groupsUrl/$groupId/join");

    return GroupUser.fromJson(groupUser.data);
  }

  static Future<void> leaveGroup(int groupId) async {
    var dio = APIService.getDio();

    await dio.post("$groupsUrl/$groupId/leave");
  }

  static Future<GroupUser> joinGroupWithCode(String code) async {
    var dio = APIService.getDio();
    var groupUser = await dio.post('$groupsUrl/join', data: {
      'code': code,
    });

    return GroupUser.fromJson(groupUser.data);
  }
}
