import 'package:map_domain/src/entities/geo_point.dart';

final class UserLocation {
  const UserLocation({required this.point, required this.accuracyMeters});
  final GeoPoint point;
  final double accuracyMeters;
}
