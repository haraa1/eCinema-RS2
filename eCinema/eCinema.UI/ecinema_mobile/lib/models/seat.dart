import 'package:json_annotation/json_annotation.dart';
import 'seat_type.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  int? id;
  String? row;
  int? number;
  bool? isAvailable;
  int? seatTypeId;
  int? cinemaHallId;
  SeatType? seatType;

  Seat({
    this.id,
    this.row,
    this.number,
    this.isAvailable,
    this.seatTypeId,
    this.cinemaHallId,
    this.seatType,
  });

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}
