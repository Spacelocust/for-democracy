import 'package:mobile/services/secure_storage_service.dart';

class TokenService {
  Future<String?> getToken() async {
    return await SecureStorageService().readSecureData("token");
  }

  Future<void> setToken(String token) async {
    await SecureStorageService().writeSecureData("token", token);
  }

  Future<void> deleteToken() async {
    await SecureStorageService().deleteSecureData("token");
  }
}
