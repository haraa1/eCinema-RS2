import 'dart:convert';
import 'dart:io';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:ecinema_mobile/utils/utils.dart' as Utils;
import 'package:http/http.dart' as _client;
import 'package:http/io_client.dart';
import 'package:ecinema_mobile/utils/utils.dart';
import 'package:ecinema_mobile/models/user.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super('User');

  bool _busy = false;
  User? _current;
  User? get current => _current;

  @override
  User fromJson(data) => User.fromJson(data);

  Future<void> register(User newUser) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}User/register');
    final resp = await http!.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(newUser.toJson()),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Registration failed: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> loadCurrentUser() async {
    if (_busy || _current != null) return;
    _busy = true;
    notifyListeners();

    try {
      final res = await http!.get(
        Uri.parse('${BaseProvider.baseUrl}User/me'),
        headers: createHeaders(),
      );

      if (res.statusCode == 200) {
        _current = User.fromJson(jsonDecode(res.body));
      } else {
        debugPrint('loadCurrentUser failed (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      debugPrint('Exception loading user: $e');
    }

    _busy = false;
    notifyListeners();
  }
}
