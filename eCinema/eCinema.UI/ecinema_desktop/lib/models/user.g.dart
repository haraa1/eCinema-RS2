// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  userName: json['userName'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  confirmPassword: json['confirmPassword'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  roleIds:
      (json['roleIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
)..roles = (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'email': instance.email,
  'password': instance.password,
  'confirmPassword': instance.confirmPassword,
  'phoneNumber': instance.phoneNumber,
  'roleIds': instance.roleIds,
  'roles': instance.roles,
};
