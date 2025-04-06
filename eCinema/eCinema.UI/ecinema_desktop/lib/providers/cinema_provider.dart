import 'package:ecinema_desktop/models/cinema.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class CinemaProvider extends BaseProvider<Cinema> {
  CinemaProvider() : super("Cinema");

  @override
  Cinema fromJson(data) => Cinema.fromJson(data);
}
