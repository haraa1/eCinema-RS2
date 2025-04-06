// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cinema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cinema _$CinemaFromJson(Map<String, dynamic> json) => Cinema(
  (json['id'] as num?)?.toInt(),
  json['name'] as String?,
  json['city'] as String?,
  json['address'] as String?,
);

Map<String, dynamic> _$CinemaToJson(Cinema instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'city': instance.city,
  'address': instance.address,
};
