import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
  });
  final String id;
  final String email;
  final String displayName;
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
