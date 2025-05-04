// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
  id: (json['id'] as num?)?.toInt(),
  row: json['row'] as String?,
  number: (json['number'] as num?)?.toInt(),
  isAvailable: json['isAvailable'] as bool?,
  seatTypeId: (json['seatTypeId'] as num?)?.toInt(),
  cinemaHallId: (json['cinemaHallId'] as num?)?.toInt(),
  seatType:
      json['seatType'] == null
          ? null
          : SeatType.fromJson(json['seatType'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
  'id': instance.id,
  'row': instance.row,
  'number': instance.number,
  'isAvailable': instance.isAvailable,
  'seatTypeId': instance.seatTypeId,
  'cinemaHallId': instance.cinemaHallId,
  'seatType': instance.seatType,
};
