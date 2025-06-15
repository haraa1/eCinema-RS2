import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int id;
  final int bookingId;
  final int amount;
  final String currency;
  final String stripePaymentIntentId;
  final String? stripeChargeId;

  @JsonKey(fromJson: paymentStatusFromString)
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

enum PaymentStatus { pending, succeeded, failed, refunded, unknown }

PaymentStatus paymentStatusFromString(dynamic statusValue) {
  if (statusValue == null) return PaymentStatus.unknown;

  if (statusValue is String) {
    switch (statusValue.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'succeeded':
        return PaymentStatus.succeeded;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unknown;
    }
  } else if (statusValue is int) {
    switch (statusValue) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.succeeded;
      case 2:
        return PaymentStatus.failed;
      case 3:
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unknown;
    }
  }
  return PaymentStatus.unknown;
}
