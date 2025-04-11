// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'showtime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Showtime _$ShowtimeFromJson(Map<String, dynamic> json) => Showtime(
  id: (json['id'] as num?)?.toInt(),
  movieId: (json['movieId'] as num?)?.toInt(),
  cinemaHallId: (json['cinemaHallId'] as num?)?.toInt(),
  startTime:
      json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
  endTime:
      json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
  basePrice: (json['basePrice'] as num?)?.toDouble(),
  movie:
      json['movie'] == null
          ? null
          : Movie.fromJson(json['movie'] as Map<String, dynamic>),
  cinemaHall:
      json['cinemaHall'] == null
          ? null
          : CinemaHall.fromJson(json['cinemaHall'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShowtimeToJson(Showtime instance) => <String, dynamic>{
  'id': instance.id,
  'movieId': instance.movieId,
  'cinemaHallId': instance.cinemaHallId,
  'startTime': instance.startTime?.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'basePrice': instance.basePrice,
  'movie': instance.movie,
  'cinemaHall': instance.cinemaHall,
};
