// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
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
  'userId': instance.userId,
  'showtimeId': instance.showtimeId,
  'bookingTime': instance.bookingTime.toIso8601String(),
  'discountCode': instance.discountCode,
  'tickets': instance.tickets.map((e) => e.toJson()).toList(),
  'bookingConcessions':
      instance.bookingConcessions.map((e) => e.toJson()).toList(),
};
