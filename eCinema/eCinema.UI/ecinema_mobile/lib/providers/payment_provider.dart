import 'dart:convert';

import 'package:ecinema_mobile/models/payment.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("payment");

  @override
  Payment fromJson(data) => Payment.fromJson(data);

  Future<Payment> createIntent(int bookingId) async {
    final res = await post('intent/$bookingId', {});
    if (res.statusCode == 200) {
      return Payment.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create payment intent');
  }
}
