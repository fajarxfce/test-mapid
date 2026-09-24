import 'package:json_annotation/json_annotation.dart';
import 'package:map_data/src/dto/place_properties_dto.dart';
import 'package:map_data/src/dto/point_geometry_dto.dart';
part 'place_feature_dto.g.dart';

@JsonSerializable(checked: true, createToJson: false)
final class PlaceFeatureDto {
  const PlaceFeatureDto({
    required this.id,
    required this.geometry,
    required this.properties,
  });
  factory PlaceFeatureDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceFeatureDtoFromJson(json);
  final String id;
  final PointGeometryDto geometry;
  final PlacePropertiesDto properties;
}
