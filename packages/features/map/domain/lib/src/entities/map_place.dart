import 'package:map_domain/src/entities/geo_point.dart';

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
}
