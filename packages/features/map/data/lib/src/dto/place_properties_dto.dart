import 'package:json_annotation/json_annotation.dart';
part 'place_properties_dto.g.dart';

@JsonSerializable(checked: true, createToJson: false)
final class PlacePropertiesDto {
  const PlacePropertiesDto({
    this.name = '',
    this.address = '',
    this.city = '',
    this.district = '',
    this.period = '',
  });
  factory PlacePropertiesDto.fromJson(Map<String, dynamic> json) =>
      _$PlacePropertiesDtoFromJson(json);
  @JsonKey(name: 'NAMA', defaultValue: '')
  final String name;
  @JsonKey(name: 'ALAMAT', defaultValue: '')
  final String address;
  @JsonKey(name: 'KABKOT', defaultValue: '')
  final String city;
  @JsonKey(name: 'KECAMATAN', defaultValue: '')
  final String district;
  @JsonKey(name: 'WAKTU', defaultValue: '')
  final String period;
}
