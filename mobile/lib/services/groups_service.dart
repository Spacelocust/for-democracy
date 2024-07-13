import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/dto/group_dto.dart';
import 'package:mobile/models/group.dart';
import 'package:mobile/services/api_service.dart';

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
      'startAt': data.startAt.toString(),
    });

    return Group.fromJson(group.data);
  }

  static Future<Group> joinGroupWithCode(String code) async {
    var dio = APIService.getDio();
    var group = await dio.post('$groupsUrl/join', data: {
      'code': code,
    });

    return Group.fromJson(group.data);
  }
}
