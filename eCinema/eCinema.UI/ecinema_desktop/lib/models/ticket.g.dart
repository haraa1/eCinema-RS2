// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  id: (json['id'] as num).toInt(),
  bookingId: (json['bookingId'] as num).toInt(),
  seatId: (json['seatId'] as num).toInt(),
  ticketTypeId: (json['ticketTypeId'] as num).toInt(),
  price: json['price'] as num,
  bookingTime: DateTime.parse(json['bookingTime'] as String),
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'seatId': instance.seatId,
  'ticketTypeId': instance.ticketTypeId,
  'price': instance.price,
  'bookingTime': instance.bookingTime.toIso8601String(),
};
