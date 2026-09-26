import 'package:geolocator/geolocator.dart';

abstract interface class LocationAccessDataSource {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}
