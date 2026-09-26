import 'package:core_location_data/src/datasources/location_access_data_source.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocationAccessDataSource)
final class GeolocatorLocationAccessDataSource
    implements LocationAccessDataSource {
  const GeolocatorLocationAccessDataSource(this._platform);
  final GeolocatorPlatform _platform;

  @override
  Future<bool> isServiceEnabled() => _platform.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => _platform.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      _platform.requestPermission();

  @override
  Future<bool> openAppSettings() => _platform.openAppSettings();

  @override
  Future<bool> openLocationSettings() => _platform.openLocationSettings();
}
