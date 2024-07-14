import 'package:mobile/enum/objective_type.dart';

class MissionDTO {
  String name;

  String? instructions;

  List<ObjectiveType> objectives;

  MissionDTO({
    required this.name,
    this.instructions,
    required this.objectives,
  });
}
