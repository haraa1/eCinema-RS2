import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String fullName;
  @JsonKey(name: 'userName')
  final String userName;
  final String email;
  final String phoneNumber;
  final String? preferredLanguage;
  final bool? hasPicture;
  final List<String>? roles;
  final String? password;
  @JsonKey(name: 'confirmPassword')
  final String? confirmPassword;
  final String? profilePicture;
  final bool notify;

  User({
    this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    this.preferredLanguage,
    this.hasPicture,
    this.roles,
    this.password,
    this.confirmPassword,
    this.profilePicture,
    this.notify = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
