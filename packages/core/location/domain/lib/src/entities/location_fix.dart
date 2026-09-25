import 'package:core_common/core_common.dart';
import 'package:core_location_domain/src/entities/location_bearing.dart';
import 'package:equatable/equatable.dart';

final class LocationFix extends Equatable {
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

  @override
  List<Object?> get props => [point, accuracyMeters, timestamp, bearing];
}
