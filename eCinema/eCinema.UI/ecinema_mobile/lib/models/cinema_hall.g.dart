// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cinema_hall.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CinemaHall _$CinemaHallFromJson(Map<String, dynamic> json) => CinemaHall(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  capacity: (json['capacity'] as num).toInt(),
  cinemaId: (json['cinemaId'] as num).toInt(),
);

Map<String, dynamic> _$CinemaHallToJson(CinemaHall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
      'cinemaId': instance.cinemaId,
    };
