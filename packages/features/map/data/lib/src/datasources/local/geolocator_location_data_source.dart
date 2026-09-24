import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:map_data/src/datasources/local/location_data_source.dart';
import 'package:map_data/src/dto/user_location_dto.dart';

/// Owns OS permission prompts and translates platform failures at the I/O boundary.
@LazySingleton(as: LocationDataSource)
final class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource(this._platform);
  final GeolocatorPlatform _platform;

  @override
  Future<Result<UserLocationDto>> locate() async {
    try {
      if (!await _platform.isLocationServiceEnabled()) {
        return const FailureResult(
          Failure(
            FailureKind.serviceDisabled,
            'Aktifkan GPS untuk menampilkan lokasi kamu.',
          ),
        );
      }
      var permission = await _platform.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _platform.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const FailureResult(
          Failure(
            FailureKind.permissionPermanentlyDenied,
            'Izin lokasi perlu diaktifkan melalui pengaturan aplikasi.',
          ),
        );
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return const FailureResult(
          Failure(
            FailureKind.permissionDenied,
            'Izin lokasi belum diberikan. Peta wisata tetap bisa digunakan.',
          ),
        );
      }
      final position = await _platform
          .getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            ),
          )
          .timeout(const Duration(seconds: 20));
      return Success(
        UserLocationDto(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
      );
    } on TimeoutException {
      return const FailureResult(
        Failure(
          FailureKind.timeout,
          'Lokasi belum ditemukan. Coba lagi di area terbuka.',
        ),
      );
    } on LocationServiceDisabledException {
      return const FailureResult(
        Failure(FailureKind.serviceDisabled, 'GPS sedang nonaktif.'),
      );
    } on PermissionDeniedException {
      return const FailureResult(
        Failure(
          FailureKind.permissionDenied,
          'Akses lokasi ditolak oleh perangkat.',
        ),
      );
    } on PlatformException {
      return const FailureResult(
        Failure(
          FailureKind.unexpected,
          'Lokasi perangkat belum dapat diakses. Coba lagi.',
        ),
      );
    }
  }

  @override
  Future<bool> openAppSettings() => _platform.openAppSettings();
  @override
  Future<bool> openLocationSettings() => _platform.openLocationSettings();
}
