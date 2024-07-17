import 'package:app/services/api_service.dart';

abstract class LoginService {
  static const String passwordUrl = '/login';

  static Future<bool> login(String password, String username) async {
    var dio = APIService.getDio();

    return await dio.post(passwordUrl, data: {
      'password': password,
      'username': username,
    }).then((response) {
      return response.data['result'];
    });
  }
}
