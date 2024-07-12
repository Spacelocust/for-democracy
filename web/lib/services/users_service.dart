import 'package:app/models/user.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class UsersService {
  static const String usersUrl = '/users';

  static String url = '${dotenv.get(APIService.baseUrlEnv)}$usersUrl';

  static Future<List<User>> getUsers() async {
    var dio = APIService.getDio();
    var users = await dio.get(usersUrl);
    var usersData = users.data as List<dynamic>;

    return [...usersData.map((user) => User.fromJson(user))];
  }

  static Future<User> getUser(int userId) async {
    var dio = APIService.getDio();
    var user = await dio.get('$usersUrl/$userId');

    return User.fromJson(user.data);
  }
}
