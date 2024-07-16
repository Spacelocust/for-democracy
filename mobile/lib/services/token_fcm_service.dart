import 'package:mobile/services/api_service.dart';

abstract class TokenFcmService {
  static const String tokenFcmUrl = '/token-fcm';

  static Future<void> persistTokenFcm(String tokenFcm) async {
    var dio = APIService.getDio();

    await dio.post(tokenFcmUrl, data: {'token': tokenFcm});
  }
}
