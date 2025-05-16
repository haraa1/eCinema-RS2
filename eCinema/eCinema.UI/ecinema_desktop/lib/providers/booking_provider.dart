import 'package:ecinema_desktop/models/booking.dart';
import 'base_provider.dart';

class BookingProvider extends BaseProvider<Booking> {
  BookingProvider() : super("Booking");

  @override
  Booking fromJson(data) => Booking.fromJson(data);
}
