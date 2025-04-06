import 'package:json_annotation/json_annotation.dart';
part 'cinema.g.dart';

@JsonSerializable()
class Cinema {
  int? id;
  String? name;
  String? city;
  String? address;

  Cinema(this.id, this.name, this.city, this.address);

  factory Cinema.fromJson(Map<String, dynamic> json) => _$CinemaFromJson(json);
  Map<String, dynamic> toJson() => _$CinemaToJson(this);
}
