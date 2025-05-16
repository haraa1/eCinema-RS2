// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  showtimeId: (json['showtimeId'] as num).toInt(),
  bookingTime: DateTime.parse(json['bookingTime'] as String),
  discountCode: json['discountCode'] as String?,
  tickets:
      (json['tickets'] as List<dynamic>)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
  bookingConcessions:
      (json['bookingConcessions'] as List<dynamic>)
          .map((e) => BookingConcession.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'showtimeId': instance.showtimeId,
  'bookingTime': instance.bookingTime.toIso8601String(),
  'discountCode': instance.discountCode,
  'tickets': instance.tickets,
  'bookingConcessions': instance.bookingConcessions,
};
