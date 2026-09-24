// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_layer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapLayerResponse _$MapLayerResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MapLayerResponse', json, ($checkedConvert) {
      final val = MapLayerResponse(
        type: $checkedConvert('type', (v) => v as String),
        name: $checkedConvert('layer_name', (v) => v as String),
        features: $checkedConvert(
          'features',
          (v) => (v as List<dynamic>)
              .map((e) => PlaceFeatureDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'name': 'layer_name'});
