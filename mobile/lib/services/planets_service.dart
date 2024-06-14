import 'dart:convert';

import 'package:eventflux/eventflux.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/utils/sse.dart';

abstract class PlanetsService {
  static const String planetsUrl = '/planets';
  static const String planetsStreamUrl = '/planets-stream';

  static String url = '${dotenv.get(APIService.baseUrlEnv)}$planetsStreamUrl';

  static Future<List<Planet>> getPlanets() async {
    var dio = APIService.getDio();
    var planets = await dio.get(planetsUrl);
    var planetsData = planets.data as List<dynamic>;

    return planetsData.map((planet) => Planet.fromJson(planet)).toList();
  }

  static Future<Planet> getPlanet(int planetId) async {
    var dio = APIService.getDio();
    var planet = await dio.get('$planetsUrl/$planetId');

    return Planet.fromJson(planet.data);
  }

  static EventFlux getPlanetsStream({
    required Function(List<Planet>) onSuccess,
    required Function(EventFluxException) onError,
    Function()? onClose,
  }) {
    return newStream(
      url: url,
      onSuccess: (planets) {
        var planetsData = jsonDecode(planets.data) as List<dynamic>;
        var planetsList =
            planetsData.map((planet) => Planet.fromJson(planet)).toList();
        onSuccess(planetsList);
      },
      onError: onError,
      onClose: onClose,
    );
  }
}
