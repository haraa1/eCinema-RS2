import 'dart:convert';
import 'package:ecinema_desktop/models/cinema_hall.dart';
import 'package:ecinema_desktop/models/seat_distribution_item.dart';
import 'package:ecinema_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class CinemaHallProvider extends BaseProvider<CinemaHall> {
  CinemaHallProvider() : super("CinemaHall");

  @override
  CinemaHall fromJson(data) => CinemaHall.fromJson(data);

  Future<List<SeatDistributionItem>> getSeatDistribution(int id) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl}${this.endpoint}/$id/seat-distribution",
    );
    final response = await http.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => SeatDistributionItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load seat distribution");
    }
  }

  Future<void> updateSeatDistribution(
    int id,
    int totalSeats,
    List<SeatDistributionItem> distributions,
  ) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl}${this.endpoint}/$id/seat-distribution",
    );
    final body = jsonEncode({
      "TotalSeats": totalSeats,
      "Distributions": distributions.map((e) => e.toJson()).toList(),
    });

    final response = await http.put(uri, headers: createHeaders(), body: body);

    if (!isValidResponse(response)) {
      throw Exception("Failed to update seat distribution");
    }
  }

  Future<void> addSeats(int id, int numberOfSeats, int seatTypeId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}${this.endpoint}/$id/seats");
    final body = jsonEncode({
      "NumberOfSeats": numberOfSeats,
      "DefaultSeatTypeId": seatTypeId,
    });

    final response = await http.post(uri, headers: createHeaders(), body: body);

    if (!isValidResponse(response)) {
      throw Exception("Failed to add seats");
    }
  }

  Future<void> removeSeats(int id, int seatTypeId, int numberOfSeats) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}${this.endpoint}/$id/seats");
    final body = jsonEncode({
      "SeatTypeId": seatTypeId,
      "NumberOfSeats": numberOfSeats,
    });

    final response = await http.delete(
      uri,
      headers: createHeaders(),
      body: body,
    );

    if (!isValidResponse(response)) {
      throw Exception("Failed to remove seats");
    }
  }

  Future<void> bulkUpdateSeatTypes(
    int id,
    List<int> seatIds,
    int newSeatTypeId,
  ) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl}${this.endpoint}/$id/seats/bulk",
    );
    final body = jsonEncode({
      "SeatIds": seatIds,
      "NewSeatTypeId": newSeatTypeId,
    });

    final response = await http.put(uri, headers: createHeaders(), body: body);

    if (!isValidResponse(response)) {
      throw Exception("Failed to bulk update seat types");
    }
  }
}
