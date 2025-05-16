import 'package:json_annotation/json_annotation.dart';

part 'booking_concession.g.dart';

@JsonSerializable()
class BookingConcession {
  final int bookingId;
  final int concessionId;
  final int quantity;
  final num unitPrice;
  final num totalPrice;
  final DateTime bookingTime;

  BookingConcession({
    required this.bookingId,
    required this.concessionId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.bookingTime,
  });

  factory BookingConcession.fromJson(Map<String, dynamic> json) =>
      _$BookingConcessionFromJson(json);
  Map<String, dynamic> toJson() => _$BookingConcessionToJson(this);
}
