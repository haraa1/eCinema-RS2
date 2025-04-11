import 'package:json_annotation/json_annotation.dart';
import 'movie.dart';
import 'cinema_hall.dart';

part 'showtime.g.dart';

@JsonSerializable()
class Showtime {
  int? id;
  int? movieId;
  int? cinemaHallId;
  DateTime? startTime;
  DateTime? endTime;
  double? basePrice;

  Movie? movie;
  CinemaHall? cinemaHall;

  Showtime({
    this.id,
    this.movieId,
    this.cinemaHallId,
    this.startTime,
    this.endTime,
    this.basePrice,
    this.movie,
    this.cinemaHall,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) =>
      _$ShowtimeFromJson(json);
  Map<String, dynamic> toJson() => _$ShowtimeToJson(this);
}
