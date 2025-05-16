import 'package:ecinema_desktop/models/discount.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class DiscountProvider extends BaseProvider<Discount> {
  DiscountProvider() : super("Discount");

  @override
  Discount fromJson(data) => Discount.fromJson(data);
}
