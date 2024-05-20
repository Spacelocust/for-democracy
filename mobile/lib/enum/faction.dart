import 'package:json_annotation/json_annotation.dart';

enum Faction {
  @JsonValue('humans')
  humans('faction.humans'),

  @JsonValue('terminids')
  terminids('faction.terminids'),

  @JsonValue('illuminates')
  automatons('faction.illuminates'),

  @JsonValue('automatons')
  illuminates('faction.automatons');

  const Faction(this.name);

  final String name;
}
