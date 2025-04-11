import 'package:ecinema_desktop/models/showtime.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class ShowtimeProvider extends BaseProvider<Showtime> {
  ShowtimeProvider() : super("Showtime");

  @override
  Showtime fromJson(data) => Showtime.fromJson(data);
}
