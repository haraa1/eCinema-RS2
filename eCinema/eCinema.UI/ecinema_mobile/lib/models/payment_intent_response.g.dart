// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentIntentResponse _$PaymentIntentResponseFromJson(
  Map<String, dynamic> json,
) => PaymentIntentResponse(
  paymentData: Payment.fromJson(json['payment'] as Map<String, dynamic>),
  clientSecret: json['clientSecret'] as String?,
  publishableKey: json['publishableKey'] as String?,
);

Map<String, dynamic> _$PaymentIntentResponseToJson(
  PaymentIntentResponse instance,
) => <String, dynamic>{
  'payment': instance.paymentData,
  'clientSecret': instance.clientSecret,
  'publishableKey': instance.publishableKey,
};
