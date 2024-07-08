import 'package:flutter/material.dart';

class GroupsFiltersState with ChangeNotifier {
  bool _myGroups = false;

  String? _planet;

  GroupsFiltersState({
    bool myGroups = false,
    String? planet,
  })  : _myGroups = myGroups,
        _planet = planet;

  bool get myGroups => _myGroups;

  String? get planet => _planet;

  void setMyGroups(bool myGroups) {
    _myGroups = myGroups;

    notifyListeners();
  }

  void setPlanet(String? planet) {
    _planet = planet;

    notifyListeners();
  }
}
