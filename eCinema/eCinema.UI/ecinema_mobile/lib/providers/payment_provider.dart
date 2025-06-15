import 'dart:convert';

import 'package:ecinema_mobile/models/payment.dart';
import 'package:ecinema_mobile/models/payment_intent_response.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("payment");

  @override
  Payment fromJson(data) => Payment.fromJson(data);

  Future<PaymentIntentResponse> createIntent(int bookingId) async {
    final res = await http.post(
      Uri.parse('${BaseProvider.baseUrl}Payment/intent/$bookingId'),
      headers: createHeaders(),
      body: jsonEncode({}),
    );

    if (res.statusCode == 200) {
      return PaymentIntentResponse.fromJson(jsonDecode(res.body));
    } else {
      String errorMsg = 'Failed to create payment intent: ${res.statusCode}';
      try {
        final errorBody = jsonDecode(res.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          errorMsg = errorBody['message'];
        } else if (errorBody is Map && errorBody.containsKey('title')) {
          errorMsg = errorBody['title'];
        } else {
          errorMsg = res.body;
        }
      } catch (e) {
        errorMsg =
            'Failed to create payment intent: ${res.statusCode}. Response: ${res.body}';
      }
      throw Exception(errorMsg);
    }
  }
}
