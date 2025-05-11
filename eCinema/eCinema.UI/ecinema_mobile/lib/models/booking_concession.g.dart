// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_concession.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingConcession _$BookingConcessionFromJson(Map<String, dynamic> json) =>
    BookingConcession(
      bookingId: (json['bookingId'] as num).toInt(),
      concessionId: (json['concessionId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$BookingConcessionToJson(BookingConcession instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'concessionId': instance.concessionId,
      'quantity': instance.quantity,
    };
