import 'package:mobile/models/user.dart';
import 'package:mobile/services/api_service.dart';

abstract class OauthService {
  static const String oauthUrl = '/oauth/me';

  static Future<User> getMe() async {
    var dio = APIService.getDio();

    var user = await dio.get(oauthUrl);

    return User.fromJson(user.data);
  }
}
