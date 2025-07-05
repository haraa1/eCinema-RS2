// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  fullName: json['fullName'] as String,
  userName: json['userName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  preferredLanguage: json['preferredLanguage'] as String?,
  hasPicture: json['hasPicture'] as bool?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  password: json['password'] as String?,
  confirmPassword: json['confirmPassword'] as String?,
  profilePicture: json['profilePicture'] as String?,
  notify: json['notify'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'userName': instance.userName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'preferredLanguage': instance.preferredLanguage,
  'hasPicture': instance.hasPicture,
  'roles': instance.roles,
  'password': instance.password,
  'confirmPassword': instance.confirmPassword,
  'profilePicture': instance.profilePicture,
  'notify': instance.notify,
};
