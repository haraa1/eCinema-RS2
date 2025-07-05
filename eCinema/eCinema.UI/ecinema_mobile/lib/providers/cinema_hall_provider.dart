import 'dart:convert';

import 'package:ecinema_mobile/models/cinema_hall.dart';
import 'package:ecinema_mobile/models/seat.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class CinemaHallProvider extends BaseProvider<CinemaHall> {
  CinemaHallProvider() : super("CinemaHall");

  @override
  CinemaHall fromJson(data) => CinemaHall.fromJson(data);

  Future<List<Seat>> getSeatsByShowtime(int showtimeId) async {
    final uri = Uri.parse(
      '${BaseProvider.baseUrl}CinemaHall/$showtimeId/seats',
    );

    final response = await http.get(uri, headers: BaseProvider.createHeaders());

    if (isValidResponseCode(response)) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((seatJson) => Seat.fromJson(seatJson)).toList();
    } else {
      throw Exception("Failed to load seats for showtime $showtimeId");
    }
  }
}
