import 'package:ecinema_mobile/models/ticket_type.dart';
import 'base_provider.dart';

class TicketTypeProvider extends BaseProvider<TicketType> {
  TicketTypeProvider() : super('TicketType');

  @override
  TicketType fromJson(data) => TicketType.fromJson(data);
}
