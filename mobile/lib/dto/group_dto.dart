import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/models/planet.dart';

class GroupDTO {
  String name;

  String? description;

  bool private;

  Planet? planet;

  Difficulty difficulty;

  DateTime startAt;

  GroupDTO({
    required this.name,
    required this.description,
    required this.private,
    required this.planet,
    required this.difficulty,
    required this.startAt,
  });
}
