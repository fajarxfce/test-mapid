// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginResponse', json, ($checkedConvert) {
      final val = LoginResponse(
        accessToken: $checkedConvert('access_token', (v) => v as String),
        user: $checkedConvert(
          'user',
          (v) => UserDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'accessToken': 'access_token'});

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'user': instance.user.toJson(),
    };
