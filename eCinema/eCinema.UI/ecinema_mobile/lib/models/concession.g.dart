// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concession.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Concession _$ConcessionFromJson(Map<String, dynamic> json) => Concession(
  (json['id'] as num?)?.toInt(),
  json['name'] as String?,
  (json['price'] as num?)?.toDouble(),
  json['description'] as String?,
);

Map<String, dynamic> _$ConcessionToJson(Concession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
    };
