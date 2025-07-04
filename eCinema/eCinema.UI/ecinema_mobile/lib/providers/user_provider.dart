import 'dart:convert';
import 'dart:io';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:ecinema_mobile/utils/utils.dart';
import 'package:http/http.dart' as _client;
import 'package:ecinema_mobile/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super('User');

  bool _busy = false;
  User? _current;
  User? get current => _current;

  @override
  User fromJson(data) => User.fromJson(data);

  Future<void> register(User newUser) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}User/register');
    final resp = await http.post(
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
      final res = await http.get(
        Uri.parse('${BaseProvider.baseUrl}User/me'),
        headers: BaseProvider.createHeaders(),
      );

      if (res.statusCode == 200) {
        _current = User.fromJson(jsonDecode(res.body));
      } else {
        debugPrint('loadCurrentUser failed (${res.statusCode}): ${res.body}');
        _current = null;
      }
    } catch (e) {
      debugPrint('Exception loading user: $e');
      _current = null;
    }

    _busy = false;
    notifyListeners();
  }

  Future<void> updatePreferences(String language) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}User/me/preferences');
    final resp = await http.patch(
      uri,
      headers: BaseProvider.createHeaders(),
      body: jsonEncode({'preferredLanguage': language}),
    );
    if (resp.statusCode == 200) {
      _current = User.fromJson(jsonDecode(resp.body));
      notifyListeners();
    } else {
      throw Exception(
        'Failed to save preferences (${resp.statusCode}): ${resp.body}',
      );
    }
  }

  Future<void> updateProfile({
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    if (_current == null) {
      throw Exception("User not logged in.");
    }

    final Map<String, dynamic> body = {};
    if (currentPassword != null && currentPassword.isNotEmpty) {
      body['currentPassword'] = currentPassword;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      body['newPassword'] = newPassword;
    }
    if (confirmNewPassword != null && confirmNewPassword.isNotEmpty) {
      body['confirmNewPassword'] = confirmNewPassword;
    }
    if (phoneNumber != null) {
      body['phoneNumber'] = phoneNumber;
    }
    if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
      body['preferredLanguage'] = preferredLanguage;
    }

    if (body.isEmpty) {
      return;
    }

    final uri = Uri.parse('${BaseProvider.baseUrl}User/me/profile');
    final resp = await http.put(
      uri,
      headers: BaseProvider.createHeaders(),
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      _current = User.fromJson(jsonDecode(resp.body));
      notifyListeners();
    } else {
      String errorMessage = 'Failed to update profile';
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['title'] != null) {
          errorMessage = errorData['title'];
        }
      } catch (_) {}
      throw Exception('$errorMessage (${resp.statusCode})');
    }
  }

  Future<void> updateProfilePicture(File imageFile) async {
    if (_current == null) {
      throw Exception("User not logged in.");
    }

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}User/${_current!.id}/profile-picture',
    );
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(BaseProvider.createHeaders());

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 204) {
      await loadCurrentUser();
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception(
        'Failed to update profile picture (${response.statusCode}): $respStr',
      );
    }
  }

  void logout() {
    _current = null;
    Authorization.username = null;
    Authorization.password = null;
    notifyListeners();
  }

  void clearCurrentUser() {
    _current = null;
    notifyListeners();
  }
}
