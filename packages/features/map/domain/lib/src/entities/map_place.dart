import 'package:core_common/core_common.dart';

final class MapPlace {
  const MapPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.district,
    required this.period,
    required this.point,
  });
  final String id;
  final String name;
  final String address;
  final String city;
  final String district;
  final String period;
  final GeoPoint point;

  @override
  bool operator ==(Object other) =>
      other is MapPlace &&
      id == other.id &&
      name == other.name &&
      address == other.address &&
      city == other.city &&
      district == other.district &&
      period == other.period &&
      point == other.point;

  @override
  int get hashCode =>
      Object.hash(id, name, address, city, district, period, point);
}
