import 'dart:convert';
import 'package:mobile/models/planet.dart';

List<Planet> planetsFromJson(String? json) {
  if (json == null) {
    return [];
  }

  var planets = jsonDecode(json);

  if (planets == null) {
    return [];
  }

  return planets as List<Planet>;
}
