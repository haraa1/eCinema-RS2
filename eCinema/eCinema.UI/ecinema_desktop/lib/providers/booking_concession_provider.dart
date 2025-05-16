import 'package:ecinema_desktop/models/booking_concession.dart';
import 'base_provider.dart';

class BookingConcessionProvider extends BaseProvider<BookingConcession> {
  BookingConcessionProvider() : super("BookingConcessions");

  @override
  BookingConcession fromJson(data) => BookingConcession.fromJson(data);
}
