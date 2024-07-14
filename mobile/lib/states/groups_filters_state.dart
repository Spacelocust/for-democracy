import 'package:flutter/material.dart';
import 'package:mobile/enum/difficulty.dart';

class GroupsFiltersState with ChangeNotifier {
  bool _myGroups = false;

  int? _planet;

  Difficulty? _difficulty;

  GroupsFiltersState({
    bool myGroups = false,
    int? planet,
    Difficulty? difficulty,
  })  : _myGroups = myGroups,
        _planet = planet,
        _difficulty = difficulty;

  bool get myGroups => _myGroups;

  int? get planet => _planet;

  Difficulty? get difficulty => _difficulty;

  void setMyGroups(bool myGroups) {
    _myGroups = myGroups;

    notifyListeners();
  }

  void setPlanet(int? planet) {
    _planet = planet;

    notifyListeners();
  }

  void setDifficulty(Difficulty? difficulty) {
    _difficulty = difficulty;

    notifyListeners();
  }
}
