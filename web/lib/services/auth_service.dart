import 'dart:developer';

import 'package:app/models/admin.dart';
import 'package:app/services/api_service.dart';

abstract class AuthService {
  static const String passwordUrl = '/login';

  static Future<Admin?> login(String password, String username) async {
    var dio = APIService.getDio();

    try {
      final admin = await dio.post(passwordUrl, data: {
        'password': password,
        'username': username,
      });

      return Admin.fromJson(admin.data);
    } catch (e) {
      log('Error: $e');

      return null;
    }
  }
}
