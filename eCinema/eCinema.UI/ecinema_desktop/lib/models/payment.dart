import 'package:json_annotation/json_annotation.dart';
part 'payment.g.dart';

enum PaymentStatus { pending, succeeded, failed, refunded, unknown }

PaymentStatus paymentStatusFromJson(dynamic value) {
  if (value == null) return PaymentStatus.unknown;

  if (value is int) {
    return PaymentStatus.values.asMap().containsKey(value)
        ? PaymentStatus.values[value]
        : PaymentStatus.unknown;
  }

  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'succeeded':
        return PaymentStatus.succeeded;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
    }
  }
  return PaymentStatus.unknown;
}

String paymentStatusToJson(PaymentStatus s) => s.name;

@JsonSerializable(explicitToJson: true)
class Payment {
  final int id;
  final int bookingId;
  final num amount;
  final String currency;
  final String stripePaymentIntentId;
  final String? stripeChargeId;

  @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson)
  final PaymentStatus status;

  final DateTime createdAt;
  final DateTime? succeededAt;
  final DateTime? failedAt;
  final DateTime? refundedAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.stripePaymentIntentId,
    this.stripeChargeId,
    required this.status,
    required this.createdAt,
    this.succeededAt,
    this.failedAt,
    this.refundedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
