// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num).toInt(),
  bookingId: (json['bookingId'] as num).toInt(),
  amount: json['amount'] as num,
  currency: json['currency'] as String,
  stripePaymentIntentId: json['stripePaymentIntentId'] as String,
  stripeChargeId: json['stripeChargeId'] as String?,
  status: paymentStatusFromJson(json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  succeededAt:
      json['succeededAt'] == null
          ? null
          : DateTime.parse(json['succeededAt'] as String),
  failedAt:
      json['failedAt'] == null
          ? null
          : DateTime.parse(json['failedAt'] as String),
  refundedAt:
      json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'amount': instance.amount,
  'currency': instance.currency,
  'stripePaymentIntentId': instance.stripePaymentIntentId,
  'stripeChargeId': instance.stripeChargeId,
  'status': paymentStatusToJson(instance.status),
  'createdAt': instance.createdAt.toIso8601String(),
  'succeededAt': instance.succeededAt?.toIso8601String(),
  'failedAt': instance.failedAt?.toIso8601String(),
  'refundedAt': instance.refundedAt?.toIso8601String(),
};
