import 'package:json_annotation/json_annotation.dart';

import 'cinema.dart';
import 'cinema_hall.dart';
import 'movie.dart';

part 'showtime.g.dart';

@JsonSerializable()
class Showtime {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final double basePrice;
  final Movie movie;
  final CinemaHall cinemaHall;
  final Cinema cinema;

  Showtime({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.basePrice,
    required this.movie,
    required this.cinemaHall,
    required this.cinema,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) =>
      _$ShowtimeFromJson(json);

  Map<String, dynamic> toJson() => _$ShowtimeToJson(this);
}
