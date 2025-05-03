import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final int id;
  final int bookingId;
  final int seatId;
  final int ticketTypeId;
  final double price;

  Ticket({
    required this.id,
    required this.bookingId,
    required this.seatId,
    required this.ticketTypeId,
    required this.price,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);
}
