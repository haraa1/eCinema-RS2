import 'package:ecinema_mobile/models/cinema.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class CinemaProvider extends BaseProvider<Cinema> {
  CinemaProvider() : super("Cinema");

  @override
  Cinema fromJson(data) => Cinema.fromJson(data);
}
