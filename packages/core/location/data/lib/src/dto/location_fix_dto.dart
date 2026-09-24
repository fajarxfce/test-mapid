import 'package:geolocator/geolocator.dart';

final class LocationFixDto {
  const LocationFixDto({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.timestamp,
    this.heading,
    this.headingAccuracy,
    this.speed,
  });
  factory LocationFixDto.fromPosition(Position position) => LocationFixDto(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    timestamp: position.timestamp,
    heading: position.heading,
    headingAccuracy: position.headingAccuracy,
    speed: position.speed,
  );
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime? timestamp;
  final double? heading;
  final double? headingAccuracy;
  final double? speed;
}
