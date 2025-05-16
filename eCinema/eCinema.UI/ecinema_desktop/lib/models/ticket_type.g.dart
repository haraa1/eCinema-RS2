// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketType _$TicketTypeFromJson(Map<String, dynamic> json) => TicketType(
  (json['id'] as num?)?.toInt(),
  json['name'] as String?,
  (json['priceModifier'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TicketTypeToJson(TicketType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'priceModifier': instance.priceModifier,
    };
