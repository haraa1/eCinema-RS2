import '../models/showtime.dart';
import 'base_provider.dart';

class ShowtimeProvider extends BaseProvider<Showtime> {
  ShowtimeProvider() : super('Showtime');

  @override
  Showtime fromJson(data) => Showtime.fromJson(data);
}
