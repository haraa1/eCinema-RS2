import 'package:ecinema_desktop/models/payment.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  PaymentProvider() : super("Payment");

  @override
  Payment fromJson(data) => Payment.fromJson(data);
}
