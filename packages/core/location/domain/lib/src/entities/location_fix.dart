import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_bearing.dart';

final class LocationFix {
  const LocationFix({
    required this.point,
    required this.accuracyMeters,
    this.timestamp,
    this.bearing,
  });
  final GeoPoint point;
  final double accuracyMeters;
  final DateTime? timestamp;
  final LocationBearing? bearing;
}
