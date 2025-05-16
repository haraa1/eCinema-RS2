import 'package:ecinema_desktop/models/ticket.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super("Ticket");

  @override
  Ticket fromJson(data) => Ticket.fromJson(data);
}
