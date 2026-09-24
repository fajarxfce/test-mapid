import 'package:core_common/core_common.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:geolocator/geolocator.dart';

final class LocationFixDto {
  const LocationFixDto({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.timestamp,
    this.course,
  });
  factory LocationFixDto.fromPosition(Position position) => LocationFixDto(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    timestamp: position.timestamp,
    // A stationary GPS course does not describe the direction the device faces.
    course:
        position.speed >= 0.5 &&
            position.heading.isFinite &&
            position.heading >= 0 &&
            position.headingAccuracy >= 0
        ? position.heading % 360
        : null,
  );
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime? timestamp;
  final double? course;

  LocationFix toEntity({double? compassHeading}) => LocationFix(
    point: GeoPoint(latitude: latitude, longitude: longitude),
    accuracyMeters: accuracy,
    timestamp: timestamp,
    bearing: compassHeading != null
        ? LocationBearing(
            degrees: compassHeading,
            source: LocationBearingSource.compass,
          )
        : course != null
        ? LocationBearing(
            degrees: course!,
            source: LocationBearingSource.movement,
          )
        : null,
  );
}
