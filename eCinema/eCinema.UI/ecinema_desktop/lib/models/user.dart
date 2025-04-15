import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  String? userName;
  String? email;
  String? password;
  String? confirmPassword;
  String? phoneNumber;
  List<int>? roleIds;
  List<String>? roles;

  User({
    this.id,
    this.userName,
    this.email,
    this.password,
    this.confirmPassword,
    this.phoneNumber,
    this.roleIds,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
