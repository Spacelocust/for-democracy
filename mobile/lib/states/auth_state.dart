import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/user.dart';

class AuthState with ChangeNotifier, DiagnosticableTreeMixin {
  String? _token;

  AuthState({String? token}) : _token = token;

  String? get token => _token;

  Future<User?> getUser() async {
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);

      return User.fromJson(decodedToken['payload']);
    }

    return null;
  }

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  /// Makes `Auth` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('token', token));
  }
}
