import 'package:mobile/models/planet.dart';
import 'package:mobile/services/api_service.dart';

abstract class PlanetsService {
  static const String planetsUrl = '/planets';

  static Future<List<Planet>> getPlanets() async {
    var dio = APIService.getDio();
    var planets = await dio.get(planetsUrl);
    var planetsData = planets.data as List<dynamic>;

    return planetsData.map((planet) => Planet.fromJson(planet)).toList();
  }
}
