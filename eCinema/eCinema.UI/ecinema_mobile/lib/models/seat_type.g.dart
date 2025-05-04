// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeatType _$SeatTypeFromJson(Map<String, dynamic> json) => SeatType(
  (json['id'] as num?)?.toInt(),
  json['name'] as String?,
  (json['priceMultiplier'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SeatTypeToJson(SeatType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'priceMultiplier': instance.priceMultiplier,
};
