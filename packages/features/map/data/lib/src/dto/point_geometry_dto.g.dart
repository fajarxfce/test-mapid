// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_geometry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointGeometryDto _$PointGeometryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PointGeometryDto', json, ($checkedConvert) {
      final val = PointGeometryDto(
        type: $checkedConvert('type', (v) => v as String),
        coordinates: $checkedConvert(
          'coordinates',
          (v) =>
              (v as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
        ),
      );
      return val;
    });
