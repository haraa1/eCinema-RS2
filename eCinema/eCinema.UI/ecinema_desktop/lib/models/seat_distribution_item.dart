class SeatDistributionItem {
  int seatTypeId;
  int count;

  SeatDistributionItem({required this.seatTypeId, required this.count});

  factory SeatDistributionItem.fromJson(Map<String, dynamic> json) {
    return SeatDistributionItem(
      seatTypeId: json['seatTypeId'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {"SeatTypeId": seatTypeId, "Count": count};
}
