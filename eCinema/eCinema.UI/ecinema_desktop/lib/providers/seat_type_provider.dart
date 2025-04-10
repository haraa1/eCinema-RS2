import 'package:ecinema_desktop/models/seat_type.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class SeatTypeProvider extends BaseProvider<SeatType> {
  SeatTypeProvider() : super("SeatType");

  @override
  SeatType fromJson(data) => SeatType.fromJson(data);
}
