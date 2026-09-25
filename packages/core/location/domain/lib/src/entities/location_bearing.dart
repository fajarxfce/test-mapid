import 'package:core_location_domain/src/entities/location_bearing_source.dart';
import 'package:equatable/equatable.dart';

/// Degrees clockwise from north. Compass readings use magnetic north.
final class LocationBearing extends Equatable {
  const LocationBearing({required this.degrees, required this.source});
  final double degrees;
  final LocationBearingSource source;

  @override
  List<Object> get props => [degrees, source];
}
