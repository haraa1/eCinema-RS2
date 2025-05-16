import 'package:ecinema_desktop/models/ticket_type.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class TicketTypeProvider extends BaseProvider<TicketType> {
  TicketTypeProvider() : super("TicketType");

  @override
  TicketType fromJson(data) => TicketType.fromJson(data);
}
