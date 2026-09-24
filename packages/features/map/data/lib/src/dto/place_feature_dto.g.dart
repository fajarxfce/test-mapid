// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_feature_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceFeatureDto _$PlaceFeatureDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlaceFeatureDto', json, ($checkedConvert) {
      final val = PlaceFeatureDto(
        id: $checkedConvert('id', (v) => v as String),
        geometry: $checkedConvert(
          'geometry',
          (v) => PointGeometryDto.fromJson(v as Map<String, dynamic>),
        ),
        properties: $checkedConvert(
          'properties',
          (v) => PlacePropertiesDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });
