import 'package:core_location_data/src/datasources/geolocator_location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class _Platform extends Mock implements GeolocatorPlatform {}

void main() {
  setUpAll(() => registerFallbackValue(const LocationSettings()));
  test(
    'reading GPS returns a DTO without checking or requesting access',
    () async {
      final platform = _Platform();
      when(
        () => platform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer(
        (_) async => Position(
          longitude: 110.36,
          latitude: -7.8,
          timestamp: DateTime(2026),
          accuracy: 12,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      );
      final result = await GeolocatorLocationDataSource(platform).locate();
      expect(result, isA<LocationFixDto>());
      expect(result.latitude, -7.8);
      expect(result.longitude, 110.36);
      verifyNever(platform.isLocationServiceEnabled);
      verifyNever(platform.checkPermission);
      verifyNever(platform.requestPermission);
      verifyNever(platform.openAppSettings);
    },
  );

  test('a native permission error reaches the caller unchanged', () async {
    final platform = _Platform();
    final error = PermissionDeniedException('Native denial');
    when(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(error);
    await expectLater(
      GeolocatorLocationDataSource(platform).locate(),
      throwsA(same(error)),
    );
    verifyNever(platform.requestPermission);
  });
}
