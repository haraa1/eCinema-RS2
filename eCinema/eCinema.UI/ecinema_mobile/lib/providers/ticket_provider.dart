import 'package:ecinema_mobile/models/ticket.dart';
import 'base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super('Ticket');

  @override
  Ticket fromJson(data) => Ticket.fromJson(data);
}
