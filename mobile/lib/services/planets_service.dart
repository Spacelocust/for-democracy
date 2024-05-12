import 'dart:convert';
import 'dart:io';
import 'package:mobile/models/planet.dart';
import 'package:mobile/services/api_service.dart';

abstract class PlanetsService {
  static const String planetsUrl = '/planets';

  static Future<List<Planet>> getPlanets() async {
    // var dio = APIService.getDio();
    // var planets = await dio.get(planetsUrl);
    // var planetsData =
    //     jsonDecode(planets.data.toString()) as Map<String, dynamic>;

    // return planetsData.entries
    //     .map((planet) => Planet.fromJson(planet.value))
    //     .toList();

    // Fake data for now
    return Future.delayed(const Duration(seconds: 10), () {
      return List.generate(
        10,
        (index) => Planet(
          id: index,
          name: 'Planet $index',
          disabled: false,
          helldiversID: index,
          players: 0,
          positionX: 0,
          positionY: 0,
          regeneration: 0,
          health: 0,
          maxHealth: 0,
        ),
      );
    });
  }
}
