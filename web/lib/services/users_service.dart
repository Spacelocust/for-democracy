import 'package:app/models/user.dart';
import 'package:app/services/api_service.dart';

abstract class UsersService {
  static const String usersUrl = '/users';

  static Future<List<User>> getUsers() async {
    var dio = APIService.getDio();
    var users = await dio.get(usersUrl);
    var usersData = users.data as List<dynamic>;

    return [...usersData.map((user) => User.fromJson(user))];
  }
}
