import 'package:json_annotation/json_annotation.dart';

part 'seat_type.g.dart';

@JsonSerializable()
class SeatType {
  int? id;
  String? name;
  double? priceMultiplier;

  SeatType(this.id, this.name, this.priceMultiplier);

  factory SeatType.fromJson(Map<String, dynamic> json) =>
      _$SeatTypeFromJson(json);
  Map<String, dynamic> toJson() => _$SeatTypeToJson(this);
}
