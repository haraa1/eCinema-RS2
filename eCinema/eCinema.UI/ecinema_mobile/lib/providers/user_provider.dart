import 'dart:convert';
import 'dart:io';
import 'package:ecinema_mobile/providers/base_provider.dart';
import 'package:http/io_client.dart';
import 'package:ecinema_mobile/utils/utils.dart';
import 'package:ecinema_mobile/models/user.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super('User');

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
}
