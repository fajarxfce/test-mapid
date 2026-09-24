import 'package:json_annotation/json_annotation.dart';
import 'package:map_data/src/dto/place_feature_dto.dart';
part 'map_layer_response.g.dart';

@JsonSerializable(checked: true, createToJson: false)
final class MapLayerResponse {
  const MapLayerResponse({
    required this.type,
    required this.name,
    required this.features,
  });
  factory MapLayerResponse.fromJson(Map<String, dynamic> json) =>
      _$MapLayerResponseFromJson(json);
  final String type;
  @JsonKey(name: 'layer_name')
  final String name;
  final List<PlaceFeatureDto> features;
}
