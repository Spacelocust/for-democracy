import 'dart:convert';
import 'dart:ui' as ui;
import 'package:mobile/models/planet.dart';
import 'package:mobile/utils/canvas.dart';

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

Future<Map<int, ui.Image>> getPlanetsImagesFuture(
  List<Planet> planets,
) async {
  Map<int, ui.Image> images = {};

  await Future.wait(planets.map((planet) {
    return loadImage(planet.imageUrl!);
  }).toList());

  for (Planet planet in planets) {
    var image = await loadImage(planet.imageUrl!);

    images.update(
      planet.id,
      (value) => image,
      ifAbsent: () => image,
    );
  }

  return images;
}
