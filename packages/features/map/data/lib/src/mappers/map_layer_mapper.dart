import 'package:core_common/core_common.dart';
import 'package:map_data/src/dto/map_layer_response.dart';
import 'package:map_data/src/dto/place_feature_dto.dart';
import 'package:map_domain/map_domain.dart';

MapLayer mapLayer(MapLayerResponse response) {
  if (response.type != 'FeatureCollection') {
    throw const FormatException('Expected a GeoJSON FeatureCollection.');
  }
  final places = response.features.map(mapPlace).toList();
  if (places.map((place) => place.id).toSet().length != places.length) {
    throw const FormatException('Feature IDs must be unique.');
  }
  return MapLayer(name: response.name, places: places);
}

MapPlace mapPlace(PlaceFeatureDto feature) {
  final coordinates = feature.geometry.coordinates;
  if (feature.id.trim().isEmpty ||
      feature.geometry.type != 'Point' ||
      coordinates.length < 2 ||
      !coordinates[0].isFinite ||
      !coordinates[1].isFinite ||
      coordinates[0].abs() > 180 ||
      coordinates[1].abs() > 90) {
    throw const FormatException('Invalid point feature.');
  }
  final properties = feature.properties;
  return MapPlace(
    id: feature.id,
    name: properties.name,
    address: properties.address,
    city: properties.city,
    district: properties.district,
    period: properties.period,
    point: GeoPoint(latitude: coordinates[1], longitude: coordinates[0]),
  );
}
