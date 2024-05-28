import 'package:mobile/models/user.dart';
import 'package:mobile/services/api_service.dart';

abstract class OAuthService {
  static const String oAuthUrl = '/oauth/me';

  static Future<User> getMe() async {
    var dio = APIService.getDio();

    var user = await dio.get(oAuthUrl);

    return User.fromJson(user.data);
  }
}
