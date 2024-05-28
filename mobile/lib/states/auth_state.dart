import 'package:flutter/foundation.dart';
import 'package:mobile/models/user.dart';

class AuthState with ChangeNotifier, DiagnosticableTreeMixin {
  User? _user;

  AuthState({User? user}) : _user = user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  /// Makes `Auth` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('user', user.toString()));
  }
}
