import 'package:json_annotation/json_annotation.dart';
part 'point_geometry_dto.g.dart';

@JsonSerializable(checked: true, createToJson: false)
final class PointGeometryDto {
  const PointGeometryDto({required this.type, required this.coordinates});
  factory PointGeometryDto.fromJson(Map<String, dynamic> json) =>
      _$PointGeometryDtoFromJson(json);
  final String type;
  final List<double> coordinates;
}
