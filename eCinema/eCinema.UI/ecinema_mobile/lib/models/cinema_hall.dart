import 'package:json_annotation/json_annotation.dart';

part 'cinema_hall.g.dart';

@JsonSerializable()
class CinemaHall {
  final int id;
  final String name;
  final int capacity;
  final int cinemaId;

  CinemaHall({
    required this.id,
    required this.name,
    required this.capacity,
    required this.cinemaId,
  });

  factory CinemaHall.fromJson(Map<String, dynamic> json) =>
      _$CinemaHallFromJson(json);

  Map<String, dynamic> toJson() => _$CinemaHallToJson(this);
}
