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
      unitPrice: json['unitPrice'] as num,
      totalPrice: json['totalPrice'] as num,
      bookingTime: DateTime.parse(json['bookingTime'] as String),
    );

Map<String, dynamic> _$BookingConcessionToJson(BookingConcession instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'concessionId': instance.concessionId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'bookingTime': instance.bookingTime.toIso8601String(),
    };
