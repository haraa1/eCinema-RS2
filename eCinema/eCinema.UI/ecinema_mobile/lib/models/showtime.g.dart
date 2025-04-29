// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'showtime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Showtime _$ShowtimeFromJson(Map<String, dynamic> json) => Showtime(
  id: (json['id'] as num).toInt(),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  basePrice: (json['basePrice'] as num).toDouble(),
  movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
  cinemaHall: CinemaHall.fromJson(json['cinemaHall'] as Map<String, dynamic>),
  cinema: Cinema.fromJson(json['cinema'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShowtimeToJson(Showtime instance) => <String, dynamic>{
  'id': instance.id,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'basePrice': instance.basePrice,
  'movie': instance.movie,
  'cinemaHall': instance.cinemaHall,
  'cinema': instance.cinema,
};
