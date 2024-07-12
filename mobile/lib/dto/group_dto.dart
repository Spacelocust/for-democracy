import 'package:mobile/models/planet.dart';

class GroupDTO {
  String name;

  String? description;

  bool isPrivate;

  Planet? planet;

  GroupDTO({
    required this.name,
    required this.description,
    required this.isPrivate,
    required this.planet,
  });
}
