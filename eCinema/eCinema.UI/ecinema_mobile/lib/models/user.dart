import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'userName')
  final String userName;
  final String email;
  final String password;
  @JsonKey(name: 'confirmPassword')
  final String confirmPassword;
  final String phoneNumber;

  User({
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
