import 'dart:async';

import 'package:core_common/core_common.dart';
import 'package:core_location_data/src/datasources/compass_data_source.dart';
import 'package:core_location_data/src/datasources/geolocator_location_data_source.dart';
import 'package:core_location_data/src/dto/location_fix_dto.dart';
import 'package:core_location_data/src/exceptions/location_permission_exception.dart';
import 'package:core_location_data/src/repositories/device_location_repository.dart';
import 'package:core_location_domain/core_location_domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class _Geolocator extends Mock implements GeolocatorPlatform {}

class _Compass extends Mock implements CompassDataSource {}

void main() {
  late _Geolocator platform;
  late GeolocatorLocationDataSource source;
  setUpAll(() => registerFallbackValue(const LocationSettings()));
  setUp(() {
    platform = _Geolocator();
    source = GeolocatorLocationDataSource(platform);
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => true);
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
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
  });
  test('maps a real platform fix into the domain with accuracy', () async {
    final repository = DeviceLocationRepository(source, _Compass());
    final result = await repository.locate() as Success<LocationFix>;
    expect(result.value.point.latitude, -7.8);
    expect(result.value.point.longitude, 110.36);
    expect(result.value.accuracyMeters, 12);
    verifyNever(platform.requestPermission);
  });
  test('asks for permission once and continues when granted', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    when(platform.requestPermission)
        .thenAnswer((_) async => LocationPermission.whileInUse);
    expect(await source.locate(), isA<LocationFixDto>());
    verify(platform.requestPermission).called(1);
  });
  test('denial does not query the GPS position', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    when(platform.requestPermission)
        .thenAnswer((_) async => LocationPermission.denied);
    await expectLater(
      source.locate(),
      throwsA(
        isA<LocationPermissionException>().having(
          (error) => error.permission,
          'permission',
          LocationPermission.denied,
        ),
      ),
    );
    verifyNever(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    );
  });
  test('permanent denial offers an application-settings recovery', () async {
    when(platform.checkPermission)
        .thenAnswer((_) async => LocationPermission.deniedForever);
    await expectLater(
      source.locate(),
      throwsA(
        isA<LocationPermissionException>().having(
          (error) => error.permission,
          'permission',
          LocationPermission.deniedForever,
        ),
      ),
    );
    verifyNever(platform.requestPermission);
    when(platform.openAppSettings).thenAnswer((_) async => true);
    expect(
      await DeviceLocationRepository(
        source,
        _Compass(),
      ).openSettings(LocationSettingsTarget.application),
      isA<Success<void>>(),
    );
    verify(platform.openAppSettings).called(1);
  });
  test('disabled GPS is distinct from denied permission', () async {
    when(platform.isLocationServiceEnabled).thenAnswer((_) async => false);
    await expectLater(
      source.locate(),
      throwsA(isA<LocationServiceDisabledException>()),
    );
    verifyNever(platform.checkPermission);
    when(platform.openLocationSettings).thenAnswer((_) async => true);
    expect(
      await DeviceLocationRepository(
        source,
        _Compass(),
      ).openSettings(LocationSettingsTarget.device),
      isA<Success<void>>(),
    );
  });
  test('a GPS timeout is recoverable', () async {
    when(
      () => platform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(TimeoutException('private'));
    await expectLater(source.locate(), throwsA(isA<TimeoutException>()));
    final result =
        await DeviceLocationRepository(source, _Compass()).locate()
            as FailureResult<LocationFix>;
    expect(result.failure.kind, FailureKind.timeout);
    expect(result.failure.message, isNot(contains('private')));
  });
  test(
    'a settings launch failure is returned through the shared result',
    () async {
      when(platform.openAppSettings).thenAnswer((_) async => false);
      expect(await source.openAppSettings(), isFalse);
      final result = await DeviceLocationRepository(
        source,
        _Compass(),
      ).openSettings(LocationSettingsTarget.application);
      expect(result, isA<FailureResult<void>>());
    },
  );
  test(
    'datasource preserves platform errors; repository translates them',
    () async {
      when(platform.openLocationSettings).thenThrow(
        PlatformException(
          code: 'unavailable',
          message: 'private device details',
        ),
      );
      await expectLater(
        source.openLocationSettings,
        throwsA(isA<PlatformException>()),
      );
      final result = await DeviceLocationRepository(
        source,
        _Compass(),
      ).openSettings(LocationSettingsTarget.device) as FailureResult<void>;
      expect(result.failure.kind, FailureKind.unexpected);
      expect(result.failure.message, isNot(contains('private device details')));
    },
  );
}
