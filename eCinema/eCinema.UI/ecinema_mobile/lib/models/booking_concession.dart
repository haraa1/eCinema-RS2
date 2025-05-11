import 'package:json_annotation/json_annotation.dart';

part 'booking_concession.g.dart';

@JsonSerializable()
class BookingConcession {
  final int bookingId;
  final int concessionId;
  final int quantity;

  BookingConcession({
    required this.bookingId,
    required this.concessionId,
    required this.quantity,
  });

  factory BookingConcession.fromJson(Map<String, dynamic> json) =>
      _$BookingConcessionFromJson(json);

  Map<String, dynamic> toJson() => _$BookingConcessionToJson(this);
}
