import 'package:identity_data/src/dto/user_dto.dart';
import 'package:identity_domain/identity_domain.dart';

extension UserDtoMapper on UserDto {
  User toEntity() => User(id: id, email: email, displayName: displayName);
}
