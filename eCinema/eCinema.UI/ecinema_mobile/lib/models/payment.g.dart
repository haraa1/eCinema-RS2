// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  clientSecret: json['clientSecret'] as String,
  publishableKey: json['publishableKey'] as String,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'clientSecret': instance.clientSecret,
  'publishableKey': instance.publishableKey,
};
