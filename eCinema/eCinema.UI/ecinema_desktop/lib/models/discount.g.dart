// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Discount _$DiscountFromJson(Map<String, dynamic> json) => Discount(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  discountPercentage: json['discountPercentage'] as num,
  validFrom: DateTime.parse(json['validFrom'] as String),
  validTo: DateTime.parse(json['validTo'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$DiscountToJson(Discount instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'discountPercentage': instance.discountPercentage,
  'validFrom': instance.validFrom.toIso8601String(),
  'validTo': instance.validTo.toIso8601String(),
  'isActive': instance.isActive,
};
