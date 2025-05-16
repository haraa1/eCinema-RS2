import 'package:json_annotation/json_annotation.dart';

part 'ticket_type.g.dart';

@JsonSerializable()
class TicketType {
  int? id;
  String? name;
  double? priceModifier;

  TicketType(this.id, this.name, this.priceModifier);

  factory TicketType.fromJson(Map<String, dynamic> json) =>
      _$TicketTypeFromJson(json);
  Map<String, dynamic> toJson() => _$TicketTypeToJson(this);
}
