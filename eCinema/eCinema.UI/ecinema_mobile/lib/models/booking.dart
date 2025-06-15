import 'package:json_annotation/json_annotation.dart';
import 'ticket.dart';
import 'booking_concession.dart';

part 'booking.g.dart';

@JsonSerializable(explicitToJson: true)
class Booking {
  final int id;
  final int userId;
  final int showtimeId;
  final DateTime bookingTime;
  final String? discountCode;
  final List<Ticket> tickets;
  final List<BookingConcession> bookingConcessions;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.bookingTime,
    this.discountCode,
    required this.tickets,
    required this.bookingConcessions,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
