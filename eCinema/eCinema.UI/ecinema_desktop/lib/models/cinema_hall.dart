import 'package:json_annotation/json_annotation.dart';
import 'seat.dart';

part 'cinema_hall.g.dart';

@JsonSerializable()
class CinemaHall {
  int? id;
  String? name;
  int? capacity;
  int? cinemaId;
  String? cinemaName;
  List<Seat>? seats;

  CinemaHall({
    this.id,
    this.name,
    this.capacity,
    this.cinemaId,
    this.cinemaName,
    this.seats,
  });

  factory CinemaHall.fromJson(Map<String, dynamic> json) =>
      _$CinemaHallFromJson(json);

  Map<String, dynamic> toJson() => _$CinemaHallToJson(this);
}
