import 'package:json_annotation/json_annotation.dart';
part 'concession.g.dart';

@JsonSerializable()
class Concession {
  int? id;
  String? name;
  double? price;
  String? description;

  Concession(this.id, this.name, this.price, this.description);

  factory Concession.fromJson(Map<String, dynamic> json) =>
      _$ConcessionFromJson(json);
  Map<String, dynamic> toJson() => _$ConcessionToJson(this);
}
