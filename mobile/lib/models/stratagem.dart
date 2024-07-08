import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/enum/stratagem_type.dart';
import 'package:mobile/enum/stratagem_use_type.dart';

part 'stratagem.g.dart';

@JsonSerializable()
class Stratagem {
  @JsonKey(required: true, name: 'ID')
  final int id;

  @JsonKey(name: 'CodeName')
  final String? codeName;

  @JsonKey(required: true, name: 'Name')
  final String name;

  @JsonKey(name: 'UseCount')
  final int? useCount;

  @JsonKey(required: true, name: 'UseType')
  final StratagemUseType useType;

  @JsonKey(required: true, name: 'Cooldown')
  final int cooldown;

  @JsonKey(required: true, name: 'Activation')
  final int activation;

  @JsonKey(required: true, name: 'ImageURL')
  final String imageURL;

  @JsonKey(required: true, name: 'Type')
  final StratagemType type;

  @JsonKey(required: true, name: 'Keys')
  final List keys;

  Stratagem({
    required this.id,
    this.codeName,
    required this.name,
    this.useCount,
    required this.useType,
    required this.cooldown,
    required this.activation,
    required this.imageURL,
    required this.type,
    required this.keys,
  });

  factory Stratagem.fromJson(Map<String, dynamic> json) =>
      _$StratagemFromJson(json);

  Map<String, dynamic> toJson() => _$StratagemToJson(this);
}
