import 'package:ecinema_mobile/models/cinema_hall.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';

class CinemaHallProvider extends BaseProvider<CinemaHall> {
  CinemaHallProvider() : super("CinemaHall");

  @override
  CinemaHall fromJson(data) => CinemaHall.fromJson(data);
}
