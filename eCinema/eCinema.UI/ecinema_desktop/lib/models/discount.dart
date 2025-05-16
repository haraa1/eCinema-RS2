import 'package:json_annotation/json_annotation.dart';

part 'discount.g.dart';

@JsonSerializable()
class Discount {
  final int id;
  final String code;
  final num discountPercentage;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isActive;

  Discount({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.validFrom,
    required this.validTo,
    required this.isActive,
  });

  factory Discount.fromJson(Map<String, dynamic> json) =>
      _$DiscountFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountToJson(this);
}
