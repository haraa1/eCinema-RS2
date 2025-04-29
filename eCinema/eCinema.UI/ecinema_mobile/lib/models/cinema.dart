import 'package:json_annotation/json_annotation.dart';

part 'cinema.g.dart';

@JsonSerializable()
class Cinema {
  final int id;
  final String name;
  final String city;
  final String address;

  Cinema({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) => _$CinemaFromJson(json);

  Map<String, dynamic> toJson() => _$CinemaToJson(this);
}
