import 'dart:convert';
import 'package:ecinema_mobile/models/booking.dart';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as _client;

class BookingProvider extends BaseProvider<Booking> {
  BookingProvider() : super('Booking');

  bool _busy = false;
  String? _error;
  List<Booking> _items = [];

  bool get isLoading => _busy;
  String? get error => _error;
  List<Booking> get items => List.unmodifiable(_items);

  @override
  Booking fromJson(data) => Booking.fromJson(data);

  Future<void> loadMyBookings() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${BaseProvider.baseUrl}Booking/me');
      final res = await _client.get(uri, headers: createHeaders());

      if (res.statusCode == 200) {
        final jsonList = jsonDecode(res.body) as List<dynamic>;
        _items =
            jsonList
                .map((e) => Booking.fromJson(e as Map<String, dynamic>))
                .toList();
        _error = null;
      } else {
        _error =
            'Failed to load bookings: ${res.statusCode} ${res.reasonPhrase}';
        debugPrint(_error);
      }
    } catch (e) {
      _error = 'Exception while loading bookings: $e';
      debugPrint(_error);
    }

    _busy = false;
    notifyListeners();
  }

  Future<Booking?> create(Map<String, dynamic> data) async {
    return await insert(data);
  }
}
