// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_properties_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacePropertiesDto _$PlacePropertiesDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PlacePropertiesDto',
      json,
      ($checkedConvert) {
        final val = PlacePropertiesDto(
          name: $checkedConvert('NAMA', (v) => v as String? ?? ''),
          address: $checkedConvert('ALAMAT', (v) => v as String? ?? ''),
          city: $checkedConvert('KABKOT', (v) => v as String? ?? ''),
          district: $checkedConvert('KECAMATAN', (v) => v as String? ?? ''),
          period: $checkedConvert('WAKTU', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'name': 'NAMA',
        'address': 'ALAMAT',
        'city': 'KABKOT',
        'district': 'KECAMATAN',
        'period': 'WAKTU',
      },
    );
