import 'package:flutter/foundation.dart';
import 'package:mobile/models/planet.dart';

class PlanetsState with ChangeNotifier, DiagnosticableTreeMixin {
  List<Planet> _planets;

  PlanetsState({List<Planet>? planets}) : _planets = planets ?? [];

  List<Planet> get planets => _planets;

  void setPlanets(List<Planet> planets) {
    _planets = planets;
    notifyListeners();
  }

  Planet getPlanet(id) {
    return planets.firstWhere((planet) => planet.id == id);
  }

  /// Makes `Planets` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('planets', planets.toString()));
  }
}
