import 'package:mobile/services/api_service.dart';

abstract class OauthService {
  static void logout() async {
    var dio = APIService.getDio();
    await dio.get('/oauth/logout/steam');
  }
}
