import 'package:app/models/group.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
}
