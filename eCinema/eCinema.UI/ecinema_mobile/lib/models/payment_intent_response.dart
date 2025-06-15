import 'package:json_annotation/json_annotation.dart';
import 'payment.dart'; // wherever your Payment class lives

part 'payment_intent_response.g.dart';

@JsonSerializable()
class PaymentIntentResponse {
  @JsonKey(name: 'payment')
  final Payment paymentData;

  final String? clientSecret;
  final String? publishableKey;

  PaymentIntentResponse({
    required this.paymentData,
    this.clientSecret,
    this.publishableKey,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentIntentResponseToJson(this);
}
