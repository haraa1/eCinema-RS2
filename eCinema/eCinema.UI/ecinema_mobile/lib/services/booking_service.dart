import 'dart:convert';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:ecinema_mobile/providers/booking_state.dart';
import 'package:ecinema_mobile/providers/movie_provider.dart';
import 'package:http/http.dart' as http;

Future<void> submitBooking(BookingState state) async {
  final uri = Uri.parse("https://10.0.2.2:7012/Booking");

  final selectedConcessions = state.selectedConcessions;

  final body = {
    "showtimeId": state.showtimeId,
    "bookingTime": DateTime.now().toIso8601String(),
    "discountCode": "",
    "bookingConcessions":
        selectedConcessions.entries
            .map((e) => {"concessionId": e.key, "quantity": e.value})
            .toList(),
    "tickets":
        state.tickets
            .map(
              (t) => {
                "seatId": t.seatId,
                "ticketTypeId": t.ticketTypeId,
                "price": t.price,
              },
            )
            .toList(),
  };

  try {
    final response = await http.post(
      uri,
      headers: BaseProvider.createHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Booking successful");
    } else {
      print("Failed to submit booking: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("Error submitting booking: $e");
  }
}
